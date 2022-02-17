# 弊社で使っているチャットアプリへの通知用module
module Tocaro
  class Notifier
    class << self
      def send_notice(color: nil, text: nil, attachments: nil)
        notice = new
        notice.color = color
        notice.text = text
        notice.attachments = attachments
        notice.exec
      end

      def info(text: nil, attachments: nil)
        send_notice(color: 'info',
                    text: text,
                    attachments: attachments)
      end

      def success(text: nil, attachments: nil)
        send_notice(color: 'success',
                    text: text,
                    attachments: attachments)
      end

      def warning(text: nil, attachments: nil)
        send_notice(color: 'warning',
                    text: text,
                    attachments: attachments)
      end

      def danger(text: nil, attachments: nil)
        send_notice(color: 'danger',
                    text: text,
                    attachments: attachments)
      end
    end

    def initialize
      api_key = Rails.application.credentials.dig(:tocaro, :api_key)
      url = "https://hooks.tocaro.im/integrations/inbound_webhook/#{api_key}"
      @uri = URI.parse(url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @payload = {}
    end

    def text=(text)
      @payload[:text] = text
    end

    # color = ['info', 'warning', 'danger', 'success']
    def color=(color)
      @payload[:color] = color
    end

    def attachments=(attachments)
      @payload[:attachments] = [attachments] if attachments.class == Hash
      @payload[:attachments] = attachments if attachments.class == Array
    end

    def exec
      headers = { 'Content-Type' => 'application/json' }
      begin
        res = @http.post(@uri.path, @payload.to_json, headers)
        if res.class.ancestors.include?(Net::HTTPClientError)
          Notifier.danger(text: 'Tocaroへの通知でエラーが発生しました',
                          attachments: { title: 'エラー内容', value: res.body })
        end
      rescue StandardError => e
        p e
      end
    end
  end
end
