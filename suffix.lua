-- Curtis Fenner
-- Lua 5.1 Suffix Tree implementation

--------------------------------------------------------------------------------
-- A SUFFIX TREE is an index of suffixes (and also substrings) of lists.
-- It enables fast substring queries after doing linear pre-processing on the
-- document to query.

-- The interface has only a single method:
	-- :search(substr) -> bool
--------------------------------------------------------------------------------

-- LIBRARY OVERVIEW

-- SuffixTree.new(list)
-- Makes a new suffix tree for the given list.
-- Linear in the length of list.
-- REQUIRES list is not empty.

-- SuffixTree:search(sublist)
-- Returns whether or not the given sublist appears as a contiguous subarray in
-- the list passed to the constructor.
-- Linear in the length of sublist.
-- REQUIRES list is not empty.

--------------------------------------------------------------------------------

local function sliceLength(t)
	return t[2] - t[1] + 1
end

local function sliceGet(t, i)
	return t[3][t[1] + i - 1]
end

local SuffixTree = {}

local min = math.min

local function matchingPrefix(tree, slice)
	for i = 1, #tree do
		local key, subtree = tree[i][1], tree[i][2]
		if sliceGet(slice, 1) == sliceGet(key, 1) then
			local limit = min(sliceLength(key), sliceLength(slice))
			for k = 1, limit do
				if sliceGet(slice, k) ~= sliceGet(key, k) then
					return i, k - 1
				end
			end
			return i, limit
		end
	end
end

local function insert(tree, slice)
	local index, common = matchingPrefix(tree, slice)
	if not index then
		-- Insert a new substring.
		tree[#tree + 1] = {slice, {}}
		return
	else
		local pair = tree[index]
		local oldKey = pair[1]
		local oldSubtree = pair[2]
		
		-- Split the key where they are common.
		local remainder = {}
		local branch = {
			{{oldKey[1] + common, oldKey[2], oldKey[3]}, oldSubtree},
			{{slice[1] + common, slice[2], slice[3]}, remainder},
		}
		tree[index] = {{oldKey[1], oldKey[1] + common - 1, oldKey[3]}, branch}
		return insert(remainder, {slice[1] + common, slice[2], slice[3]})
	end
end

-- RETURNS a SuffixTree constructed for the given list.
-- REQUIRES that the list's elements, with respect to `==`, are never mutated
-- after being passed to this constructor.
-- REQUIRES list is not empty (in particular, strings cannot be passed to
-- SuffixTree; they must be "exploded" into lists of characters).
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
	local index, common = matchingPrefix(tree, query)
	if not index then
		return false
	elseif common == sliceLength(query) then
		return true
	end
	return search(tree[index][2], {query[1] + common, query[2], query[3]})
end

-- RETURNS whether the given substr appears as a contiguous subarray of the list
-- passed to this SuffixTree's constructor.
-- REQUIRES that substr is not empty.
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

if false then
	for n = 1, 200000, 10000 do
		local list = {}
		for i = 1, n do
			list[i] = math.random(3)
		end
		local before = os.clock()
		local st = SuffixTree.new(list)
		local after = os.clock()
		print(n, after - before, (after - before) / n)
	end
end
