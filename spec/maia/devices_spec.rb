describe Maia::Devices do
  describe '#tokens' do
    it 'looks up the device tokens and returns them' do
      devices = Maia::Devices.new User.all
      expect(devices.tokens.map(&:to_s))
        .to match_array %w(logan123 john123)
    end
  end

  describe '#each' do
    it 'enumerizes the tokens' do
      devices = Maia::Devices.new User.all
      expect(devices.map(&:to_s))
        .to match_array %w(logan123 john123)
    end
  end
end
