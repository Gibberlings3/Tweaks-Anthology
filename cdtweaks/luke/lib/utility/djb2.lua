--[[
+---------------------------------------------------------------------------------------------------------+
| Variant of the djb2 hash algorithm, which is highly efficient for turning a string into a numeric value |
+---------------------------------------------------------------------------------------------------------+
| DESCRIPTION:                                                                                            |
|   Initializes the hash value. The number 5381 is just an arbitrary,                                     |
|   large prime number chosen as a starting point. Using a non-zero,                                      |
|   prime initializer helps ensure a good initial mix of bits, which                                      |
|   improves the quality of the final hash                                                                |

|   Multiplies the current hash by 33. This                                                               |
|   multiplication spreads out the bits of the hash and provides strong                                   |
|   mixing. (The number 33 is used because it's 32+1, which is fast                                       |
|   for computers: it's a left bit shift by 5, plus an addition)                                          |

|   Adds the numeric ASCII/byte value of the current character to the result.                             |
|   This incorporates the unique value of the character into the hash                                     |

|   Returns the final calculated numeric hash value.                                                      |
|   This is the unique, predictable number you use for ``math.randomseed()``                              |
+---------------------------------------------------------------------------------------------------------+
--]]

function GT_Utility_DJB2(str)
	local hash = 5381
	for i = 1, #str do
		hash = (hash * 33) + string.byte(str, i)
	end
	return hash
end

