class AudioFileFetcher

  AWS_BUCKET = ENV['TWILIO_AUDIO_AWS_BUCKET_URL']

  VALID_FILE_NAMES = %w[
    closing_message
    connecting_local_rep
    connecting_to_representative
    connecting_to_senator
    connecting_local_sen
    encouraging_1
    encouraging_2
    encouraging_3
    encouraging_4
    goodbye
    intro_message
    no_connection
    no_targets
    star_to_disconnect
    user_response
  ]

  def self.audio_url_for_key(key)
    raise ArgumentError, 'Invalid audio file key' if !VALID_FILE_NAMES.include?(key)
    AWS_BUCKET + key + '.wav'
  end

  def self.encouraging_audio_for_count(connection_count)
    audio_url_for_key("encouraging_#{connection_count}")
  end

end