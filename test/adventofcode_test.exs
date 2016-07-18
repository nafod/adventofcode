defmodule AdventofcodeTest do
	use ExUnit.Case
	doctest Adventofcode

	test "day1" do
		data = File.read!("testfiles/day1.txt") |> String.rstrip
		assert Adventofcode.day1part1(data) == 74
		assert Adventofcode.day1part2(data) == 1795
	end

	test "day2" do
		data = File.read!("testfiles/day2.txt") |> String.rstrip |> String.split("\n")
		assert Enum.reduce(data, {0, 0}, fn(x, {first, second}) ->
			{first + Adventofcode.day2part1(x), second + Adventofcode.day2part2(x)}
		end) == {1606483, 3842356}
	end

	test "day3" do
		data = File.read!("testfiles/day3.txt") |> String.rstrip
		assert Adventofcode.day3part1(data) == 2592
		assert Adventofcode.day3part2(data) == 2360
	end

	test "day4" do
		assert Adventofcode.day4part1("abcdef") == 609043
		assert Adventofcode.day4part1("pqrstuv") == 1048970
		assert Adventofcode.day4part1("yzbqklnj") == 282749
		assert Adventofcode.day4part1("yzbqklnj", "000000") == 9962624
	end

	test "day5" do
		data = File.read!("testfiles/day5.txt") |> String.rstrip |> String.split("\n")
		assert Enum.reduce(data, {0, 0}, fn(x, {first, second}) ->
			{first + (case Adventofcode.day5part1(x) do
				true -> 1
				false -> 0
			end), second + (case Adventofcode.day5part2(x) do
				true -> 1
				false -> 0
			end)}
		end) == {236, 51}
	end

	test "day6" do
		data = File.read!("testfiles/day6.txt") |> String.rstrip |> String.split("\n")
		assert Adventofcode.day6part1(data) == 400410
		assert Adventofcode.day6part2(data) == 15343601
	end

	test "day7" do
		data = File.read!("testfiles/day7.txt") |> String.rstrip |> String.split("\n")
		output = Adventofcode.day7(data)
		assert Map.get(output, "a") == 16076
		output2 = Adventofcode.day7override(data, "b", Map.get(output, "a"))
		assert Map.get(output2, "a") == 2797
	end

	test "day8" do
		data = File.read!("testfiles/day8.txt") |> String.rstrip |> String.split("\n")
		assert Adventofcode.day8(data) == 1371
		assert Adventofcode.day8reverse(data) == 1
	end
end
