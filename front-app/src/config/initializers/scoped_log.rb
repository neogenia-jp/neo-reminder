require 'logger'

class Logger
  def info_scope(str = nil)
    _scoped_log('info', str) { yield if block_given? }
  end

  def debug_scope(str = nil)
    _scoped_log('debug', str) { yield if block_given? }
  end

  private
  # ブロックを囲うようにログ出力してくれるメソッド
  # +level_name+ ログレベル(debug, info, warning, error)
  # +str+ ログメッセージ(省略時はコールスタック情報より自動的に生成します)
  def _scoped_log(level_name, str, &block)
    str = _get_caller_name unless str
    self.send level_name, ">>> START >>> #{str}"
    t0 = Time.now
    block.call self if block
  ensure
    t1 = Time.now
    self.send level_name, "<<< FINISH <<< #{str} (elapsed #{sprintf '%.3f',(t1-t0)*1000} ms)"
  end

  # 呼び出し側メソッド名を返す
  def _get_caller_name
    file, line_no, method_info = caller[2].split(/:/)
    if method_info =~ /`([^']+)'/
      method_name = Regexp.last_match(1)
    end
    "#{File.basename(file)}:#{line_no}:#{method_name}"
  end
end
