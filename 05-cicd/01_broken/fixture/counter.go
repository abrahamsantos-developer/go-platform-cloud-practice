package fixture

func AddMany(n int) int {
	count := 0
	for i := 0; i < n; i++ {
		count++
	}
	return count
}
