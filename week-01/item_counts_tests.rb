# Tests summing multiple items
p item_counts([1,2,1,2,1]) == {1 => 3, 2 => 2}

# Tests case sensitivity
p item_counts(["a","b","a","b","a","ZZZ"]) == {"a" => 3, "b" => 2, "ZZZ" => 1}

# Tests no-value case
p item_counts([]) == {}

# Tests identity case
p item_counts(["hi", "hi", "hi"]) == {"hi" => 3}

# Tests different types of values
p item_counts([true, nil, "dinosaur"]) == {true => 1, nil => 1, "dinosaur" => 1}

# Tests serial values and case sensitivity
p item_counts(["a","a","A","A"]) == {"a" => 2, "A" => 2}
