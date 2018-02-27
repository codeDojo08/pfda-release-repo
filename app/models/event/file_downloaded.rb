class Event::FileDownloaded < Event

  event_attribute :file_size, db_column: :param1
  event_attribute :dxid, db_column: :param2
  event_attribute :dxuser
  event_attribute :org_handle

  def self.create(file, user)
    super(
      dxid: file.dxid,
      file_size: file.file_size,
      dxuser: user.dxuser,
      org_handle: user.org.handle
    )
  end

end
