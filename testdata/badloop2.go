package example

func ComplexIf() {
	for i := uint64(0); ; {
		if i < 4 { // ERROR implicit loop continue
			i = 0
			continue
		}
	}
}