class TextMailer < ApplicationMailer
  def text_mail(to: nil, cc: nil, bcc: nil, from: nil, subject: nil, body: nil)
    mail(
      to: to,
      cc: cc,
      bcc: bcc,
      from: from,
      subject: subject,
      body: body
    )
  end
end
