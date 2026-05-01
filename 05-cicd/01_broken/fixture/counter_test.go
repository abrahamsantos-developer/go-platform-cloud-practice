package fixture

import (
	"sync"
	"testing"
)

func TestRace(t *testing.T) {
	var value int
	var wg sync.WaitGroup

	for i := 0; i < 8; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := 0; j < 1000; j++ {
				value++
			}
		}()
	}

	wg.Wait()
	if value == 0 {
		t.Fatal("unexpected zero value")
	}
}
