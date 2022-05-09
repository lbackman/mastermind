# frozen_string_literal: true

# Methods for randomly generating sequences
def create_array(repeat = false)
  options = (1..6).to_a
  result = []
  4.times do
    rand = options.sample
    result << rand
    options.delete(rand) unless repeat
  end
  result
end
