# frozen_string_literal: true

Rails.application.config.to_prepare do
  Rails.autoloaders.main.push_dir(Rails.root.join('app/domain'))
end
