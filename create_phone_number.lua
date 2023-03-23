local create_phone_number = function(numbers)
    return string.format("(%s%s%s) %s%s%s-%s%s%s%s", table.unpack(numbers))
end

print(create_phone_number({ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }))
print(create_phone_number({ 5, 5, 5, 6, 4, 7, 6, 4, 2, 7 }))
print(create_phone_number({ 0, 2, 4, 6, 8, 9, 7, 5, 3, 1 }))
print(create_phone_number({ 0, 4, 4, 7, 0, 0, 7, 0, 7, 0 }))
print(create_phone_number({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }))