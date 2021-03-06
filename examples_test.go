// These end-to-end tests run Goose over complete packages and test the Coq
// output.
//
// The examples are packages in internal/examples/.
// Tests in package pkg have a Ast pkg.gold.v with the expected Coq output.
// The Ast is generated by freezing the output of goose and then some manual
// auditing. They serve especially well as regression tests when making
// changes that are expected to have no impact on existing working code,
// and also conveniently are continuously-checked examples of goose output.
//
// There are also negative examples in testdata/ that goose rejects due to
// unsupported Go code. These are each run as a standalone package.
package goose_test

import (
	"bytes"
	"flag"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"io/ioutil"
	"os"
	"path"
	"regexp"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/tchajed/goose"
)

var updateGold = flag.Bool("update-gold",
	false,
	"update *.gold.v files in internal/examples/ with current output")

type test struct {
	name string
	path string
}

func newTest(dir string, name string) test {
	return test{name: name, path: path.Join(dir, name)}
}

func loadTests(dir string) []test {
	f, err := os.Open(dir)
	if err != nil {
		panic(err)
	}
	defer f.Close()
	names, err := f.Readdirnames(0)
	if err != nil {
		panic(err)
	}
	var tests []test
	for _, n := range names {
		tests = append(tests, newTest(dir, n))
	}
	return tests
}

func (t test) isDir() bool {
	info, _ := os.Stat(t.path)
	return info.IsDir()
}

// A positiveTest is a test organized as a directory with expected Coq output
//
// Each test is a single Go package in dir that has a Ast <dir>.gold.v
// with the expected Coq output.
type positiveTest struct {
	test
}

// GoldFile returns the path to the test's gold Coq output
func (t positiveTest) GoldFile() string {
	return path.Join(t.path, t.name+".gold.v")
}

// ActualFile returns the path to the test's actual output
func (t positiveTest) ActualFile() string {
	return path.Join(t.path, t.name+".actual.v")
}

// Gold returns the contents of the gold Ast as a string
func (t positiveTest) Gold() string {
	expected, err := ioutil.ReadFile(t.GoldFile())
	if err != nil {
		return ""
	}
	return string(expected)
}

// UpdateGold updates the gold output with real results
func (t positiveTest) UpdateGold(actual string) {
	err := ioutil.WriteFile(t.GoldFile(), []byte(actual), 0644)
	if err != nil {
		panic(err)
	}
}

// PutActual updates the actual test output with the real results
func (t positiveTest) PutActual(actual string) {
	err := ioutil.WriteFile(t.ActualFile(), []byte(actual), 0644)
	if err != nil {
		panic(err)
	}
}

// DeleteActual deletes the actual test output, if it exists
func (t positiveTest) DeleteActual() {
	_ = os.Remove(t.ActualFile())
}

func testExample(testingT *testing.T, name string, conf goose.Config) {
	assert := assert.New(testingT)
	t := positiveTest{newTest("internal/examples", name)}
	if !t.isDir() {
		assert.FailNowf("not a test directory",
			"path: %s",
			t.path)
	}
	// c.Logf("testing example %s/", t.Path)

	f, terr := conf.TranslatePackage("", t.path)
	if terr != nil {
		fmt.Fprintln(os.Stderr, terr)
		assert.FailNow("translation failed")
	}

	var b bytes.Buffer
	f.Write(&b)
	actual := b.String()

	if *updateGold {
		expected := t.Gold()
		if actual != expected {
			fmt.Fprintf(os.Stderr, "updated %s\n", t.GoldFile())
		}
		t.UpdateGold(actual)
		t.DeleteActual()
		return
	}

	expected := t.Gold()
	if expected == "" {
		assert.FailNowf("could not load gold output",
			"gold file: %s",
			t.GoldFile())
	}
	if actual != expected {
		assert.FailNowf("actual Coq output != gold output",
			"see %s",
			t.ActualFile())
		t.PutActual(actual)
		return
	}
	// when tests pass, clean up actual output
	t.DeleteActual()
}

func TestUnitTests(t *testing.T) {
	testExample(t, "unittest", goose.Config{})
}

func TestSimpleDb(t *testing.T) {
	testExample(t, "simpledb", goose.Config{})
}

func TestWal(t *testing.T) {
	testExample(t, "wal", goose.Config{TypeCheck: true})
}

func TestLogging2(t *testing.T) {
	testExample(t, "logging2", goose.Config{TypeCheck: true})
}

func TestAppendLog(t *testing.T) {
	testExample(t, "append_log", goose.Config{TypeCheck: true})
}

func TestRfc1813(t *testing.T) {
	testExample(t, "rfc1813", goose.Config{TypeCheck: true})
}

func TestSemantics(t *testing.T) {
	testExample(t, "semantics", goose.Config{TypeCheck: true})
}

type errorExpectation struct {
	Line  int
	Error string
}

type errorTestResult struct {
	Err        *goose.ConversionError
	ActualLine int
	Expected   errorExpectation
}

func getExpectedError(fset *token.FileSet,
	comments []*ast.CommentGroup) *errorExpectation {
	errRegex := regexp.MustCompile(`ERROR ?(.*)`)
	for _, cg := range comments {
		for _, c := range cg.List {
			ms := errRegex.FindStringSubmatch(c.Text)
			if ms == nil {
				continue
			}
			expected := &errorExpectation{
				Line: fset.Position(c.Pos()).Line,
			}
			// found a match
			if len(ms) > 1 {
				expected.Error = ms[1]
			}
			// only use the first ERROR
			return expected
		}
	}
	return nil
}

func translateErrorFile(assert *assert.Assertions, filePath string) *errorTestResult {
	fset := token.NewFileSet()
	pkgName := "example"
	ctx := goose.NewCtx(pkgName, fset, goose.Config{})
	f, err := parser.ParseFile(fset, filePath, nil, parser.ParseComments)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		assert.FailNowf("test code for %s does not parse", filePath)
		return nil
	}

	err = ctx.TypeCheck(pkgName, []*ast.File{f})
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		assert.FailNowf("test code for %s does not type check", filePath)
		return nil
	}

	_, errs := ctx.Decls(goose.NamedFile{Path: filePath, Ast: f})
	if len(errs) == 0 {
		assert.FailNowf("expected error while translating %s", filePath)
		return nil
	}
	cerr := errs[0].(*goose.ConversionError)

	expectedErr := getExpectedError(fset, f.Comments)
	if expectedErr == nil {
		assert.FailNowf("test code for %s does not have an error expectation",
			filePath)
		return nil
	}

	return &errorTestResult{
		Err:        cerr,
		ActualLine: fset.Position(cerr.Pos).Line,
		Expected:   *expectedErr,
	}
}

func TestNegativeExamples(testingT *testing.T) {
	tests := loadTests("./testdata")
	for _, t := range tests {
		if t.isDir() {
			continue
		}
		testingT.Run(t.name, func(testingT *testing.T) {
			assert := assert.New(testingT)
			tt := translateErrorFile(assert, t.path)
			if tt == nil {
				// this Ast has already failed
				return
			}
			assert.Regexp(`(unsupported|future)`, tt.Err.Category)
			if !strings.Contains(tt.Err.Message, tt.Expected.Error) {
				assert.FailNowf(`%s: error message "%s" does not contain "%s"`,
					t.name, tt.Err.Message, tt.Expected.Error)
			}
			if tt.ActualLine > 0 && tt.ActualLine != tt.Expected.Line {
				assert.FailNowf("%s: error is incorrectly attributed to %s",
					t.name, tt.Err.GoSrcFile)
			}
		})
	}
}
