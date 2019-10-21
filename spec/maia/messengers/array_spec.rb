describe Maia::Messengers::Array do
  it 'adds messages to an array' do
    subject.deliver :test1
    subject.deliver :test2
    expect(subject.messages).to eq [:test1, :test2]
  end

  it 'enumerizes the array of JSON-parsed messages' do
    subject.deliver({ test: 1}.to_json)
    expect(subject.to_a).to eq [{ "test" => 1 }]
  end
end
