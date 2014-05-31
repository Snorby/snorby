class Setting

  CHECKBOXES = [
    :utc,
    :event_notifications,
    :update_notifications,
    :daily,
    :weekly,
    :monthly,
    :lookups,
    :notes,
    :packet_capture,
    :packet_capture_auto_auth,
    :autodrop,
    :geoip
  ]

  include DataMapper::Resource

  property :name, String, :key => true, :index => true, :required => false

  property :value, Object

  def checkbox?
    return true if CHECKBOXES.include?(name.to_sym)
    false
  end

  def self.set(name, value=nil)
    record = first(:name => name)
    return Setting.create(:name => name, :value => value) if record.nil?
    record.update(:value => value)
  end

  def self.find(name)
    record = first(:name => name)
    return false if record.nil?
    return false if record.value.is_a?(Integer) && record.value.zero?
    record.value
  end

  def self.has_setting(name)
    record = first(:name => name)
    return false if record.nil?
    return false if record.value.is_a?(Integer) && record.value.zero?
    return true unless record.value.blank?
    false
  end

  def self.file(name, file)
    new_file_name = file.original_filename.sub(/(\w+)(?=\.)/, "#{name}")
    new_file_path = "#{Rails.root.to_s}/public/system/#{new_file_name}"

    FileUtils.mv(file.tempfile.path, new_file_path)
    self.set(:logo, "#{Snorby::CONFIG[:baseuri]}/system/#{new_file_name}")
  end

  def self.method_missing(method, *args)
    if method.to_s.match(/^all/)
      super
    elsif method.to_s.match(/^(.*)=$/)
      return Setting.set($1, args.first)
    elsif method.to_s.match(/^(.*)\?$/)
      Setting.has_setting($1.to_sym)
    else
      return Setting.get(method.to_sym)
    end
  end

end
