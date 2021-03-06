RSpec.describe Dry::Validation::Schema, 'for an array' do
  context 'without type specs' do
    subject(:schema) do
      Dry::Validation.Schema do
        each do
          schema do
            required(:prefix).filled
            required(:value).filled
          end
        end
      end
    end

    it 'applies its rules to array input' do
      result = schema.([{ prefix: 1, value: 123 }, { prefix: 2, value: 456 }])

      expect(result).to be_success

      result = schema.([{ prefix: 1, value: nil }, { prefix: nil, value: 456 }])

      expect(result.messages).to eql(
        0 => { value: ["must be filled"] },
        1 => { prefix: ["must be filled"] }
      )
    end
  end

  context 'with type specs' do
    subject(:schema) do
      Dry::Validation.Params do
        configure { config.type_specs = true }

        each do
          schema do
            required(:prefix, :integer).filled
            required(:value, :integer).filled
          end
        end
      end
    end

    it 'applies its rules to coerced array input' do
      result = schema.([{ prefix: 1, value: '123' }, { prefix: 2, value: 456 }])

      expect(result).to be_success

      expect(result.output).to eql(
        [{ prefix: 1, value: 123 }, { prefix: 2, value: 456 }]
      )

      result = schema.([{ prefix: 1, value: nil }, { prefix: nil, value: 456 }])

      expect(result.messages).to eql(
        0 => { value: ["must be filled"] },
        1 => { prefix: ["must be filled"] }
      )
    end
  end

  context 'with hight-level rules' do
    subject(:schema) do
      Dry::Validation.Schema do
        each do
          schema do
            required(:prefix).filled
            required(:value).filled

            rule(prefix_value: [:prefix, :value]) do |prefix, value|
              prefix.gt?(1).then(value.gt?(100))
            end
          end
        end
      end
    end

    it 'applies its hight-level rules to array input' do
      result = schema.([{ prefix: 1, value: 42 }, { prefix: 2, value: 123 }])

      expect(result).to be_success

      result = schema.([{ prefix: 2, value: 42 }, { prefix: 3, value: 89 }])

      expect(result.messages).to eql(
        0 => { prefix_value: ['must be greater than 100'] },
        1 => { prefix_value: ['must be greater than 100'] }
      )
    end
  end
end
