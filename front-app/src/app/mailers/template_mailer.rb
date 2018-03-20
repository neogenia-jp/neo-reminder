# mailTemplateテーブルからテンプレートを取得するメール処理の親クラス
class TemplateMailer < ApplicationMailer
  def mail_with_template(type, convert_params, options = {})
    mt = template(type)
    raise RuntimeError.new "メールテンプレート'#{type}'が見つかりません。" unless mt
    mt.convert_params = convert_params
    mail(
      to: options[:to],
      cc: options[:cc],
      bcc: options[:bcc],
      reply_to: mt.from,
      from: %Q/"#{mt.from_name}" <#{mt.from}>/,
      subject: mt.converted_subject,
      body: mt.full_body
    )
  end

  private
  def template(type)
    MailTemplate.by_type(type)
  end
end
