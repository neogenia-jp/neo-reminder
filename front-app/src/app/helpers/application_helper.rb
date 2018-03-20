module ApplicationHelper
  def current_func_selector(current_func, target_func)
    if [*target_func].include? current_func
      'class="nowMenu"'.html_safe
    else
      ''
    end
  end

  # meta-tag を出力する
  def output_meta_tags
    if display_meta_tags.blank?
      assign_meta_tags
    end
    display_meta_tags
  end

  # meta-tag を紐付ける
  def assign_meta_tags(options = {})
    if display_meta_tags.blank?
      defaults = t('meta_tags.defaults')

      a = breadcrumbs.map(&:name).delete_if{|x| %w/バリュートレンド HOME/.include? x}.reverse
      title = a.join(' | ')
      a << defaults[:site]
      full_title = a.join(' | ')

      configs = {
        separator: '|',
        reverse: true,
        site: defaults[:site],
        title: title,
        description: defaults[:description],
        keywords: defaults[:keywords],
        canonical: request.original_url,
        og: {
            type: 'article',
            title: full_title,
            description: defaults[:description],
            url: request.original_url,
            image: defaults[:image],
            site_name: defaults[:site],
        }
      }
      options = configs.merge options
    end
    set_meta_tags options
  end

  # image_tag をオーバーライド
  def image_tag(source, options={})
    # altが指定されておらず、class が 'icon-xxx' であれば alt=nil とする。
    # h1 タグ内の img.alt が Google 検索結果のタイトルに表示されてしまうため。
    unless options.has_key? :alt
      options[:alt] = nil if options[:class]&.index 'icon-'
    end
    super source, options
  end
end

