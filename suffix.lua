-- Curtis Fenner
-- Lua 5.1 Suffix Tree implementation

--------------------------------------------------------------------------------
-- A SUFFIX TREE is an index of suffixes (and also substrings) of lists.
-- It enables fast substring queries after doing linear pre-processing on the
-- document to query.

local function sliceLength(t)
	assert(#t == 3)
	return t[2] - t[1] + 1
end

local function sliceGet(t, i)
	assert(#t == 3)
	assert(1 <= i and i <= sliceLength(t), "index " .. tostring(i) .. " not in bounds [1, " .. sliceLength(t) .. "]")
	return t[3][t[1] + i - 1]
end

local SuffixTree = {}

local function matchingPrefix(tree, slice)
	for key, subtree in pairs(tree) do
		if sliceGet(slice, 1) == sliceGet(key, 1) then
			for k = 1, math.min(sliceLength(key), sliceLength(slice)) do
				if sliceGet(slice, k) ~= sliceGet(key, k) then
					return key, k - 1
				end
			end
			return key, math.min(sliceLength(key), sliceLength(slice))
		end
	end
end

local function insert(tree, slice)
	assert(slice)
	local key, common = matchingPrefix(tree, slice)
	if not key then
		-- Insert a new substring.
		tree[slice] = {}
		return
	else
		-- Split the key where they are common.
		assert(common >= 1)
		local previous = tree[key]
		tree[key] = nil
		local subtree = {}
		tree[{slice[1], slice[1] + common - 1, slice[3]}] = {
			[{key[1] + common, key[2], key[3]}] = previous,
		}
		return insert(subtree, {slice[1] + common, slice[2], slice[3]})
	end
end

-- REQUIRES that the list's elements, with respect to `==`, are never mutated
-- after being passed to this constructor.
function SuffixTree.new(list)
	local copy = {}
	for i = 1, #list do
		copy[i] = list[i]
	end
	local sentinel = {}
	copy[#copy + 1] = sentinel
	assert(#copy ~= 0)

	local instance = {
		_list = copy,
		_root = {},
	}

	for i = 1, #copy do
		insert(instance._root, {i, #copy, copy})
	end

	return setmetatable(instance, {__index = SuffixTree})
end

local function search(tree, query)
	local key, common = matchingPrefix(tree, query)
	if not key then
		return false
	end

	if common == sliceLength(query) then
		return true
	end
	return search(tree[key], {query[1] + common, query[2], query[3]})
end

function SuffixTree:search(substr)
	assert(#substr ~= 0)
	return search(self._root, {1, #substr, substr})
end

--------------------------------------------------------------------------------

do
	local banana = SuffixTree.new {"b", "a", "n", "a", "n", "a"}
	assert(banana:search {"b", "a", "n", "a", "n", "a"})
	assert(banana:search {"b"})
	assert(banana:search {"a", "n", "a"})
	assert(banana:search {"a", "n", "a", "n"})
	assert(banana:search {"a", "n", "a", "n", "a"})
	assert(banana:search {"n", "a", "n", "a"})
	assert(not banana:search {"b", "a", "n", "a", "n", "a", "n"})
	assert(not banana:search {"n", "a", "n", "n"})
end

--------------------------------------------------------------------------------

do
	for n = 1, 10000, 100 do
		local list = {}
		for i = 1, n do
			list[i] = math.random(3)
		end
		local before = os.clock()
		local st = SuffixTree.new(list)
		local after = os.clock()
		print(n, after - before)
	end
end
