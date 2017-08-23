module LibStorj
  class FFI::Struct
    # allows for destructuring. NB: `values_at` members array order
    #   must match assignment order!
    #
    # example: ```
    #       log_options = StorjLogOptions_t.new(...)
    #       logger, level = log_options.values_at(:logger, :level)
    #       # OR logger, level = log_options.values_at([:logger, :level])
    #       # OR logger, level = log_options.values_at(%i[logger level])
    #       ```

    def values_at(*members)
      members.flatten.map {|member_name| self[member_name]}
    end

    # convenience method for inspecting struct hierarchies
    def map_layout
      # NB: Hash[ [ [key, value], ... ] ] → new_hash
      Hash[members.map do |member_name|
        member = self[member_name]
        value = member.is_a?(FFI::Struct) ? member.map_layout : member
        if value.is_a? FFI::Pointer
          next [member_name, nil] if value.null?

          # attempt to read as string
          begin
            string_value = value.read_string
            # update value to string_value if it contains only printable characters
            if string_value =~ /^[[:print:]]*$/
              value = string_value
            end
          rescue
            # do nothing...
            # let value remain a pointer if an exception was raised
          end
        end
        [member_name, value]
      end]
    end
  end
end
