module Magic
  module Link
    class MagicLink
      include ActiveModel::Model
      attr_accessor :email

      def send_login_instructions( )

        token = set_sign_in_token( )
        send_magic_link_email(token) if token
        token
      end

      private

        def user
          @user ||= Magic::Link.user_class.find_or_create_by(email: email.downcase)

          #if(@user == nil)  @user = User.create(:email => email.downcase)
        end

        def send_magic_link_email(token)
          MagicLinkMailer.send_magic_link(email, token).deliver_later
        end

        def set_sign_in_token(force: false)
          if user #&& (force || (user.sign_in_token.blank? || user.sign_in_token_sent_at < Magic::Link.token_expiration_hours.hours.ago))
            raw, enc = Devise.token_generator.generate(Magic::Link.user_class, :sign_in_token)
            user.sign_in_token = enc
            user.sign_in_token_sent_at = Time.current
            user.save(validate: false)
            raw
          else
            p 'could not create token...'
            p user
            return false
          end
        end
    end
  end
end
