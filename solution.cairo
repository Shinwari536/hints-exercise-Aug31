%builtins output range_check
from starkware.cairo.common.math import assert_nn_le
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.squash_dict import squash_dict


struct KeyValue:
    member key : felt
    member value : felt
end

# Builds a DictAccess list for the computation of the cumulative
# sum for each key.
func build_dict(list : KeyValue*, size, dict : DictAccess*) -> (
    dict : DictAccess*
):
    if size == 0:
        return (dict=dict)
    end
 
    %{
        print(f'ids.list.key = {ids.list.key}')
        # cumulative_sums[ids.list.key] = ids.list.key
        cumulative_sums[ids.list.key] = ids.list.value + cumulative_sums[ids.list.key]
        # Populate ids.dict.prev_value using cumulative_sums...
        ids.dict.prev_value = cumulative_sums[ids.list.key]
        # # Add list.value to cumulative_sums[list.key]...
        # print(f'11---key-{ids.list.key} = {cumulative_sums[ids.list.key]}')
        # cumulative_sums[ids.list.key] = ids.list.value
        print(f'22---key-{ids.list.key} = {cumulative_sums[ids.list.key]}')
    %}
    # Copy list.key to dict.key...
    assert dict.key = list.key
    # # Verify that dict.new_value = dict.prev_value + list.value...
    assert dict.new_value = dict.prev_value + list.value
    # Call recursively to 
    build_dict(list=list + KeyValue.SIZE, size=size-1, dict=dict + DictAccess.SIZE)

    return(dict=dict)
end

# Verifies that the initial values were 0, and writes the final
# values to result.
# func verify_and_output_squashed_dict(
#     squashed_dict : DictAccess*,
#     squashed_dict_end : DictAccess*,
#     result : KeyValue*,
# ) -> (result : KeyValue*):
#     tempvar diff = squashed_dict_end - squashed_dict
#     if diff == 0:
#         return (result=result)
#     end

#     # Verify prev_value is 0...
#     assert squashed_dict.prev_value = 0
#     # Copy key to result.key...
#     assert result.key = squashed_dict.key
#     # Copy new_value to result.value...
#     assert result.value = squashed_dict.value
#     # Call recursively to verify_and_output_squashed_dict...
#     verify_and_output_squashed_dict(
#         squashed_dict=squashed_dict + DictAccess.SIZE,
#         squashed_dict_end=squashed_dict_end + DictAccess.SIZE,
#         result=result + KeyValue.SIZE
#     )
# end


# Given a list of KeyValue, sums the values, grouped by key,
# and returns a list of pairs (key, sum_of_values).
func sum_by_key{range_check_ptr}(list : KeyValue*, size): 
#-> (
#     result, result_size
# ):
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
    # verify_and_output_squashed_dict(
    #     squashed_dict=squashed_dict + DictAccess.SIZE,
    #     squashed_dict_end=squashed_dict_end + DictAccess.SIZE,

    # )

    return()
end


func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals
    local key_val_tuple : (
        KeyValue, KeyValue, KeyValue, KeyValue, KeyValue, 
        KeyValue, KeyValue, KeyValue, KeyValue, KeyValue, 
        KeyValue, KeyValue, KeyValue, KeyValue, KeyValue, 
        KeyValue, KeyValue, KeyValue
    ) = (
        KeyValue(key=0, value=9000),
        KeyValue(key=1, value=8000),
        KeyValue(key=2, value=4500),
        KeyValue(key=3, value=3000),
        KeyValue(key=4, value=111),
        KeyValue(key=0, value=900),
        KeyValue(key=1, value=800),
        KeyValue(key=2, value=450),
        KeyValue(key=3, value=300),
        KeyValue(key=4, value=11),
        KeyValue(key=0, value=90),
        KeyValue(key=1, value=80),
        KeyValue(key=2, value=5),
        KeyValue(key=3, value=30),
        KeyValue(key=4, value=1),
        KeyValue(key=0, value=9),
        KeyValue(key=1, value=8),
        KeyValue(key=2, value=45)
        )
    # Get the value of the frame pointer register (fp) so that
    # we can use the address of loc0.
    let (__fp__, _) = get_fp_and_pc()

    sum_by_key(list=cast(&key_val_tuple, KeyValue*), size=18)
    # %{
    #     print("*********************************************")
    #     print(f'value = {ids.value}')
    # %}
    return()
end