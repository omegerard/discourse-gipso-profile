# name: discourse-gipso-profile
# about: My super simple plugin to demonstrate how plugins work
# version: 0.0.2
# authors: Ludo Vangilbergen EL4A
# url: https://github.com/yourusername/discourse-gipso-profile


# In plugin.rb
after_initialize do
  require File.expand_path('./app/controllers/discourse_gipso_profile/custom_feedback_controller.rb', __dir__)
  # Voeg de route toe op de klassieke manier
  Discourse::Application.routes.append do
    get '/gipso/validate' => 'discourse_gipso_profile/gipso_validation#validate_project_id'
  end
end

