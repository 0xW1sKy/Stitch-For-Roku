function select(arr, start = invalid, finish = invalid, step_ = 1):
    if step_ = 0 then print "ValueError: slice step cannot be zero" : stop
    if start = invalid then if step_ > 0 then start = 0 else start = arr.count() - 1
    if finish = invalid then if step_ > 0 then finish = arr.count() - 1 else finish = 0
    if start < 0 then start = arr.count() + start 'negative counts backwards from the end
    if finish < 0 then finish = arr.count() + finish
    res = []
    for i = start to finish step step_:
        res.push(arr[i])
    end for
    return res
end function


' Helper function to add and set fields of a content node
function AddAndSetFields(node as object, aa as object)
    'This gets called for every content node -- no logging since it's pretty verbose
    addFields = {}
    setFields = {}
    for each field in aa
        if node.hasField(field)
            setFields[field] = aa[field]
        else
            addFields[field] = aa[field]
        end if
    end for
    node.setFields(setFields)
    node.addFields(addFields)
end function
