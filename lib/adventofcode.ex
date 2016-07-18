defmodule Adventofcode do

	require Bitwise

	def day1part1(input) do
		input_s = :binary.bin_to_list(input)
		Enum.reduce(input_s, 0, fn(x, acc) ->
			case x do
				40 -> acc + 1
				41 -> acc - 1
			end
		end)
	end

	def day1part2(input) do
		input_s = :binary.bin_to_list(input) |> Enum.with_index
		Enum.reduce_while(input_s, 0, fn({x, ind}, acc) ->
			acc = cond do
				x == 40 -> acc + 1
				x == 41 -> acc - 1
			end

			cond do
				acc == -1 -> {:halt, ind}
				acc != -1 -> {:cont, acc}
			end
		end) + 1
	end

	def day2part1(input) do
		# 2*l*w + 2*w*h + 2*h*l.
		[x, y, z] = String.split(input, "x") |> Enum.map(&String.to_integer/1)
		(2 * x * y) + (2 * y * z) + (2 * x * z) + Enum.min([x * y, y * z, x * z])
	end

	def day2part2(input) do
		[x, y, z] = String.split(input, "x") |> Enum.map(&String.to_integer/1)
		Enum.min([2*x + 2*y, 2*y + 2*z, 2*x + 2*z]) + (x * y * z)
	end

	def day3part1(input) do
		data = :binary.bin_to_list(input)
		(Enum.reduce(data, {1, [{0, 0}], {0, 0}}, fn(x, {num_houses, seen, {last_x, last_y}}) ->
			pos = cond do
				x == 94 -> {last_x, last_y + 1}
				x == 118 -> {last_x, last_y - 1}
				x == 60 -> {last_x - 1, last_y}
				x == 62 -> {last_x + 1, last_y}
			end

			{num_houses + cond do
				Enum.member?(seen, pos) -> 0
				Enum.member?(seen, pos) == false -> 1
			end, seen ++ [pos], pos}
		end) |> elem(0))
	end

	def day3part2(input) do
		data = :binary.bin_to_list(input)
		(Enum.reduce(data, {1, [{0, 0}], {0, 0}, {0, 0}, true}, fn(x, {num_houses, seen, {last_x, last_y}, {last_x_robo, last_y_robo}, is_santa}) ->
			pos = cond do
				is_santa ->
					cond do
						x == 94 -> {last_x, last_y + 1}
						x == 118 -> {last_x, last_y - 1}
						x == 60 -> {last_x - 1, last_y}
						x == 62 -> {last_x + 1, last_y}
					end
				!is_santa ->
					cond do
						x == 94 -> {last_x_robo, last_y_robo + 1}
						x == 118 -> {last_x_robo, last_y_robo - 1}
						x == 60 -> {last_x_robo - 1, last_y_robo}
						x == 62 -> {last_x_robo + 1, last_y_robo}
					end
			end

			cond do
				is_santa ->
					{num_houses + cond do
						Enum.member?(seen, pos) -> 0
						Enum.member?(seen, pos) == false -> 1
					end, seen ++ [pos], pos, {last_x_robo, last_y_robo}, false}
				!is_santa ->
					{num_houses + cond do
						Enum.member?(seen, pos) -> 0
						Enum.member?(seen, pos) == false -> 1
					end, seen ++ [pos], {last_x, last_y}, pos, true}
			end
		end) |> elem(0))
	end

	def day4part1(secret, prefix \\ "00000") do
		Enum.find(1..100_000_000_000, fn(x) ->
			:crypto.hash(:md5, secret <> Integer.to_string(x)) |> Base.encode16 |> String.starts_with?(prefix)
		end)
	end

	def day5part1(input) do
		cond do
			String.contains?(input, "ab") -> false
			String.contains?(input, "cd") -> false
			String.contains?(input, "pq") -> false
			String.contains?(input, "xy") -> false
			true ->
				# Check for # of vowels and double letters
				{num_vowels, double, _} = Enum.reduce(input |> String.to_char_list, {0, false, 0}, fn(x, {num_vowels, double, last_letter}) ->
					num_vowels_inc = (case Enum.member?([97, 101, 105, 111, 117], x) do
						true -> 1
						false -> 0
					end)
					{num_vowels + num_vowels_inc, double or (last_letter == x), x}
				end)
				(num_vowels >= 3) and double
		end
	end

	def day5part2(input) do
		input_chars = String.to_char_list(input)
		{seperated, _, _} = Enum.reduce(input_chars, {false, 0, 0} , fn(x, {seperated, second, first}) ->
			{seperated or (second == x), first, x}
		end)
		{pairs, _, _, _} = Enum.reduce(input_chars, {false, [], 0, 0}, fn(x, {pairs, seen_pairs, second, first}) ->
			{pairs or (Enum.member?(seen_pairs, [first, x])), seen_pairs ++ [ [second, first] ], first, x}
		end)
		seperated and pairs
	end

	def day6part1(input) do
		lights_result = Enum.reduce(input, :array.new(1_000_000, {:default,0}), fn(line, lights) ->
			# Parse out action, coordinates, and width/length
			search_regex = ~r/(?<action>([a-z ])+) (?<x>(\d){1,3}),(?<y>(\d){1,3}) through (?<endx>(\d){1,3}),(?<endy>(\d){1,3})/
			parts = Regex.named_captures(search_regex, line)

			action = parts["action"]
			startx = String.to_integer(parts["x"])
			starty = String.to_integer(parts["y"])
			endx = String.to_integer(parts["endx"])
			endy = String.to_integer(parts["endy"])
			Enum.reduce(startx..endx, lights, fn(x, acc) ->
				Enum.reduce(starty..endy, acc, fn(y, acc_lights) ->
					lit = :array.get(x * 1000 + y, acc_lights)
					cond do
						(action == "turn on") and lit == 0 -> :array.set(x * 1000 + y, 1, acc_lights)
						(action == "turn off") and lit == 1 -> :array.set(x * 1000 + y, 0, acc_lights)
						(action == "toggle") and lit == 1 -> :array.set(x * 1000 + y, 0, acc_lights)
						(action == "toggle") and lit == 0 -> :array.set(x * 1000 + y, 1, acc_lights)
						true -> acc_lights
					end
				end)
			end)
		end)
		Enum.reduce(0..(:array.size(lights_result) - 1), 0, fn(x, acc) ->
			acc + (:array.get(x, lights_result))
		end)
	end

	def day6part2(input) do
		lights_result = Enum.reduce(input, :array.new(1_000_000, {:default,0}), fn(line, lights) ->
			# Parse out action, coordinates, and width/length
			search_regex = ~r/(?<action>([a-z ])+) (?<x>(\d){1,3}),(?<y>(\d){1,3}) through (?<endx>(\d){1,3}),(?<endy>(\d){1,3})/
			parts = Regex.named_captures(search_regex, line)

			action = parts["action"]
			startx = String.to_integer(parts["x"])
			starty = String.to_integer(parts["y"])
			endx = String.to_integer(parts["endx"])
			endy = String.to_integer(parts["endy"])
			Enum.reduce(startx..endx, lights, fn(x, acc) ->
				Enum.reduce(starty..endy, acc, fn(y, acc_lights) ->
					lit = :array.get(x * 1000 + y, acc_lights)
					cond do
						(action == "turn on") -> :array.set(x * 1000 + y, lit + 1, acc_lights)
						(action == "turn off") and lit > 0 -> :array.set(x * 1000 + y, lit - 1, acc_lights)
						(action == "toggle") -> :array.set(x * 1000 + y, lit + 2, acc_lights)
						true -> acc_lights
					end
				end)
			end)
		end)
		Enum.reduce(0..(:array.size(lights_result) - 1), 0, fn(x, acc) ->
			acc + (:array.get(x, lights_result))
		end)
	end

	def is_string_integer(input) do
		try do
			String.to_integer(input)
			true
		rescue
			_ -> false
		end
	end

	def day7op(operation, first, second \\ 0) do
		case operation do
			"AND" -> Bitwise.band(first, second)
			"OR" -> Bitwise.bor(first, second)
			"LSHIFT" -> Bitwise.bsl(first, second)
			"RSHIFT" -> Bitwise.bsr(first, second)
			"NOT" -> Bitwise.bnot(first)
			true -> first
		end
	end

	def day7(input, registers \\ Map.new) do
		# Parse each instruction
		size = map_size(registers)
		output = Enum.reduce(input, registers, fn(instruction, r) ->
			# Parse out the rule
			parts = String.split(instruction, " ")

			(cond do
				length(parts) == 3 ->
					cond do
						is_string_integer(Enum.at(parts, 0)) -> Map.put_new(r, Enum.at(parts, 2), String.to_integer(Enum.at(parts, 0)))
						Map.has_key?(r, Enum.at(parts, 0)) -> Map.put_new(r, Enum.at(parts, 2), Map.get(r, Enum.at(parts, 0)))
						true -> r
					end
				length(parts) == 4 ->
					# Figure out if the argument is set already
					cond do
						# Check if it is an integer
						is_string_integer(Enum.at(parts, 1)) ->
							Map.put_new(r, Enum.at(parts, 3), day7op(Enum.at(parts, 0), String.to_integer(Enum.at(parts, 1))))
						# Check if it is in the map
						Map.has_key?(r, Enum.at(parts, 1)) ->
							Map.put_new(r, Enum.at(parts, 3), day7op(Enum.at(parts, 0), Map.get(r, Enum.at(parts, 1))))
						# Otherwise, we have nothing to do
						true -> r
					end
				length(parts) == 5 ->
					# Figure out if our arguments are set already
					cond do
						# Check if they are both integers
						is_string_integer(Enum.at(parts, 0)) and is_string_integer (Enum.at(parts, 2)) ->
							Map.put_new(r, Enum.at(parts, 4), day7op(Enum.at(parts, 1), String.to_integer(Enum.at(parts, 0)), String.to_integer(Enum.at(parts, 2))))

						# Check if they are both values in our map
						Map.has_key?(r, Enum.at(parts, 0)) and Map.has_key?(r, Enum.at(parts, 2)) ->
							Map.put_new(r, Enum.at(parts, 4), day7op(Enum.at(parts, 1), Map.get(r, Enum.at(parts, 0)), Map.get(r, Enum.at(parts, 2))))

						# Check if one is an int and the other is in the map
						is_string_integer(Enum.at(parts, 0)) and Map.has_key?(r, Enum.at(parts, 2)) ->
							Map.put_new(r, Enum.at(parts, 4), day7op(Enum.at(parts, 1), String.to_integer(Enum.at(parts, 0)), Map.get(r, Enum.at(parts, 2))))
						is_string_integer(Enum.at(parts, 2)) and Map.has_key?(r, Enum.at(parts, 0)) ->
							Map.put_new(r, Enum.at(parts, 4), day7op(Enum.at(parts, 1), Map.get(r, Enum.at(parts, 0)), String.to_integer(Enum.at(parts, 2))))
						# The only remaining combinations involve 1 or more unset value, so just skip
						true -> r
					end
				true -> r
			end)
		end)

		cond do
			map_size(output) == size -> output
			true -> day7(input, output)
		end
	end

	def day7override(inputdata, key, value) do
		r = Map.put(%{}, key, value)
		day7(inputdata, r)
	end

	def day8(input) do
		Enum.reduce(input, 0, fn(line, total) ->
			codelength = String.length(line)
			innerlength = String.length(Regex.replace(~r/\\x[0-9a-fA-F]{2}/, Regex.replace(~r/\\\\/, Regex.replace(~r/\\"/, line, "\""), "\\"), "5")) - 2
			total + codelength - innerlength
		end)
	end

	def day8reverse(input) do
		Enum.reduce(input, 0, fn(line, total) ->
			codelength = String.length(line)
			innerlength = String.length(Regex.replace(~r/"/, String.replace(line, "\\", "\\\\"), "\\\"")) + 2
			total + innerlength - codelength
		end)
	end
end
