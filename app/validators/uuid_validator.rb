# frozen_string_literal: true

class UuidValidator < ActiveModel::Validator
  UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

  def validate(record)
    return if UUID_REGEX.match?(record.uuid.to_s)

    record.errors.add :uuid, 'Incorrect value!'
  end
end
