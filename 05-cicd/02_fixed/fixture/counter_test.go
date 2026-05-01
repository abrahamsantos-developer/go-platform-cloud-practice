package fixture

import (
	"sync"
	"testing"
)

func TestNoRace(t *testing.T) {
	results := make(chan int64, 8)
	var total int64
	var wg sync.WaitGroup

	for i := 0; i < 8; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			results <- AddMany(1000)
		}()
	}

	wg.Wait()
	close(results)

	for value := range results {
		total += value
	}

	if total != 8000 {
		t.Fatalf("unexpected total: got %d want 8000", total)
	}
}
