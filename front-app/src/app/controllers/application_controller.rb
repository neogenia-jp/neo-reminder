class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout "layouts/layout"

  # 例外ハンドラ
  rescue_from Exception,                      with: :render_500 unless Rails.env.development?
  rescue_from AppNotFoundError,               with: :render_404 unless Rails.env.development?
  rescue_from ActionController::RoutingError, with: :render_404 unless Rails.env.development?

  def handle_validation_error
    render action_name
  end

  def handle_ajax_only_error
    render nothing: true, status: :service_unavailable
  end

  def render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.pretty_log}" if e

    if request.xhr? || params[:format] == :json
      render json: { error: '404 Not Found' }, status: 404
    else
      render template: 'errors/error_404', formats: :html, status: 404, layout: 'members/layout', content_type: 'text/html', locals: { exception: e }
    end
  end

  def render_500(e = nil)
    logger.error "Rendering 500 with exception: #{e.pretty_log}" if e

    if request.xhr? || params[:format] == :json
      render json: { error: '500 Internal Server Error' }, status: 500
    else
      render template: 'errors/error_500', formats: :html, status: 500, layout: 'members/layout', content_type: 'text/html', locals: { exception: e }
    end
  end

  def allow_ajax_only!
    raise AppAjaxOnlyError.new unless request.xhr?
  end

  # Etag と Last-Modified ヘッダを付与してファイルダウンロードを行う
  def send_file_with_etag(file_path, disposition = :inline)
    f = file_path.is_a?(Pathname) ? file_path : Pathname.new(file_path)
    stat = f.stat
    filename = url_encode(File.basename(f.to_s))
    # キャッシュコントロール
    fresh_when etag: stat.mtime, last_modified: stat.mtime
    # ファイルダウンロード
    send_file f, disposition: disposition, filename: filename, length: stat.size
  end

  # 指定した文字列が書き込まれたファイルのダウンロードを行う
  def send_object_as_file(filename, obj, disposition = :inline)
    send_data_with_mime(filename, obj.to_s, disposition: disposition)
  end

  #
  # 指定したファイル名からContent-Typeを判別し、ファイルの出力を行う
  #
  # [HACK]
  #   タイプを判別するために 'mime-types' gemを使用する
  #   type_forメソッドは渡されたfilenameの拡張子に応じてタイプを判別するため、
  #   ファイルの内容からタイプを確定することはできない
  #
  #   主要であると思われる画像ファイルの拡張子については調査した結果、以下の配列が戻り値となる
  #   （タイプが複数存在する拡張子があるため、配列が戻り値となることに注意）
  #
  #     .jpg  -> [#<MIME::Type: image/jpeg>]
  #     .png  -> [#<MIME::Type: image/png>]
  #     .bmp  -> [#<MIME::Type: image/bmp>, #<MIME::Type: image/x-bmp>, #<MIME::Type: image/x-ms-bmp>]
  #     .tiff -> [#<MIME::Type: image/tiff>]
  #
  #   IE、Chrome、Safari、FireFox環境では0番目のタイプ指定で画像が表示されることを確認済み。
  #   （ただし、Chrome、FireFoxではtiffがサポートされていないため、tiffファイルは表示不可）
  #
  #   指定したタイプが不明の場合はデフォルト値である「application/octet-stream」が使用される
  #
  def send_data_with_mime(filename, data, disposition: :inline, type: nil)
    filename = url_encode(filename)
    return send_data(data, disposition: disposition, type: type.to_s, filename: filename) unless type.nil?

    # ファイル名からタイプを自動判定
    type_list = MIME::Types.type_for(filename)
    if type_list.present?
      send_data(data, disposition: disposition, type: type_list[0].to_s, filename: filename)
    else
      send_data(data, disposition: disposition, filename: filename)
    end
  end

  helper_method :url_encode
  def url_encode(str)
    ERB::Util.url_encode(str)
  end

  def full_action_name
    "#{self.class}##{action_name}"
  end
end
