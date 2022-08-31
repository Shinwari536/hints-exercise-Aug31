%builtins output range_check
from starkware.cairo.common.math import assert_nn_le
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.squash_dict import squash_dict


struct KeyValue:
    member key : felt
    member value : felt
end

# Builds a DictAccess list for the computation of the cumulative
# sum for each key.
func build_dict(list : KeyValue*, size, dict : DictAccess*) -> (
    dict
):
    if size == 0:
        return (dict=dict)
    end
 
    %{
        # Populate ids.dict.prev_value using cumulative_sums...
        ids.dict.prev_value = cumulative_sums[ids.list.key]
        # Add list.value to cumulative_sums[list.key]...
        cumulative_sums[ids.list.key] = ids.list.value
    %}
    # Copy list.key to dict.key...
    assert dict.key = list.key
    # Verify that dict.new_value = dict.prev_value + list.value...
    assert dict.new_value = dict.prev_value + list.value
    # Call recursively to 
    build_dict(list=list + KeyValue.SIZE, size=size-1, dict=dict + DictAccess.SIZE)

    return(dict=dict)
end

# Verifies that the initial values were 0, and writes the final
# values to result.
func verify_and_output_squashed_dict(
    squashed_dict : DictAccess*,
    squashed_dict_end : DictAccess*,
    result : KeyValue*,
) -> (result):
    tempvar diff = squashed_dict_end - squashed_dict
    if diff == 0:
        return (result=result)
    end

    # Verify prev_value is 0...
    # Copy key to result.key...
    # Copy new_value to result.value...
    # Call recursively to verify_and_output_squashed_dict...
end

# Given a list of KeyValue, sums the values, grouped by key,
# and returns a list of pairs (key, sum_of_values).
func sum_by_key{range_check_ptr}(list : KeyValue*, size) -> (
    result, result_size
):
    alloc_locals

    %{
        # Initialize cumulative_sums with an empty dictionary.
        # This variable will be used by ``build_dict`` to hold
        # the current sum for each key.
        cumulative_sums = {}

    %}
    # Allocate memory for dict, squashed_dict and res...
    let (local dict_start : DictAccess*) = alloc()
    let (local squashed_dict : DictAccess*) = alloc()
    # Call build_dict()...
    let (result_dict) = build_dict(
        list=list,
        size=size,
        dict=dict_start
    )
    # Call squash_dict()...
    let (squashed_dict_end : DictAccess*) = squash_dict(
        dict_accesses=dict_start,
        dict_accesses_end=result_dict,
        squashed_dict=squashed_dict,
    )
    # Call verify_and_output_squashed_dict()...
    verify_and_output_squashed_dict
end