package fixture

import "sync/atomic"

func AddMany(n int) int64 {
	var count atomic.Int64
	for i := 0; i < n; i++ {
		count.Add(1)
	}
	return count.Load()
}
