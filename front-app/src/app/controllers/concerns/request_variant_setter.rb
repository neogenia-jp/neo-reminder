module RequestVariantSetter
  extend ActiveSupport::Concern

  # ActionPack Variants の仕組みに則り、request.variant にデバイスの種類をセットすることで
  # 対応するビューファイルを自動的に振り分けてくれるようにする。
  def set_request_variant
    request.variant = :smartphone if request.from_mobilephone? ||
                                     request.from_iphone? ||
                                     request.from_ipod? ||
                                     request.from_android? ||
                                     request.from_windows_phone?
  end

  included do
    before_action :set_request_variant
  end

  # request_variant に応じて適切な AdKind を判定する
  def ad_kind_by_request_variant
    request.variant.smartphone? ? AdKind::MOBILE.id : AdKind::PC.id
  end
end
