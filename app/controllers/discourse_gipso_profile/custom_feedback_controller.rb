module DiscourseGipsoProfile
  class GipsoValidationController < ::ApplicationController
    # requires_plugin 'discourse_gipso_profile'
    # require_dependency "users_controller"
    # require_dependency "user"
    # Disable authentication callbacks if public access is needed
    skip_before_action :check_xhr, raise: false
    skip_before_action :redirect_to_login_if_required, raise: false

    def validate_project_id
      #I18n.locale = extract_locale_from_header || 'nl'
      
      # Controleer of de gebruiker is ingelogd
      if current_user.nil?
        Rails.logger.error "User not logged in"
        render json: { error: "User not logged in" }, status: 401
        return
      end

      Rails.logger.info "User logged in: #{current_user.username}"

      user = current_user
      user_custom_field_key = 'project'
      group_custom_field_key = 'gipsomember_id'
      custom_checkbox_key = 'membershipfee_paid'
      target_group_name = 'Gipsocommunity'


      user_field = UserField.find_by(name: user_custom_field_key)
      if user_field.nil?
        Rails.logger.error "User field #{user_custom_field_key} not found"
        render json: { error: "#{user_custom_field_key} field not found" }, status: 404
        return
      end

      user_custom_field_id = user_field.id
      user_custom_field_value = user.user_fields["#{user_custom_field_id}"]

      if user_custom_field_value.blank?
        Rails.logger.info "CASE 1: Opgeslagen"
        render json: { message: "Opgeslagen" }
        return
      end


      group_custom_field_values = Group.all.map { |group| group.custom_fields["#{group_custom_field_key}"] }.compact
      Rails.logger.info "HELABA: Alle gipsomemberids: #{group_custom_field_values}"

      if group_custom_field_values.include?(user_custom_field_value)
        group = Group.all.find { |group| group.custom_fields["#{group_custom_field_key}"]  == user_custom_field_value }
        group_fullname = group.title
        Rails.logger.info "HELABA: het gaat om de groep: #{group_fullname} "
        aangevinkt = group.custom_fields["#{custom_checkbox_key}"]
        Rails.logger.info "aangevinkt: #{aangevinkt} "
        if group
          group.add(user) unless group.users.include?(user)
          if group.custom_fields["#{custom_checkbox_key}"] == true
            Rails.logger.error "HELABA: DIT PROJECT HEEFT WEL DEGELIJK BETAALD"
            target_group = Group.find_by(name: target_group_name)
            target_group.add(user) if target_group && !target_group.users.include?(user)
            message = "Opgeslagen. Project is GiPSolid"
          else
            Rails.logger.error "HELABA: DIT PROJECT HEEFT NIET BETAALD"
            message = "Opgeslagen. Project geen GiPSolid"
          end
        end
      else
        message = "Opgeslagen. ProjectID niet herkend"
      end

      Rails.logger.info message
      render json: { message: message }
    end
    private

    def extract_locale_from_header
      accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
      return nil if accept_language.blank?

      # Extracteer de eerste geldige taalcode
      accept_language.split(',').map { |lang| lang.split(';').first.strip }.find do |locale|
        I18n.available_locales.map(&:to_s).include?(locale)
      end
    end
  end
end

