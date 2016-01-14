# -*- encoding : utf-8 -*-

describe Logger::Request do
  before do
    controller = double()
    allow(controller).to receive(:env) do
      hash = {}
      %w( REMOTE_ADDR REQUEST_METHOD REQUEST_URI HTTP_ACCEPT_LANGUAGE HTTP_REFERER).each do |key|
        hash[key] = key
      end
      hash
    end
    card = double()
    allow(card).to receive(:name) { 'cardname' }
    allow(controller).to receive(:card) { card }
    allow(controller).to receive(:action_name) { 'action_name' }
    allow(controller).to receive(:params) { {'view' => 'view'} }
    allow(controller).to receive(:status) { 'status' }
    Logger::Request.write_log_entry controller
  end
  it 'creates csv file' do
    expect(File.exist? Logger::Request.path).to be_truthy
  end

  describe 'log file' do
    subject { File.read Logger::Request.path }

    it { is_expected.to include 'REMOTE_ADDR' }
    it { is_expected.to include 'REQUEST_METHOD' }
    it { is_expected.to include 'view' }
    it { is_expected.to include 'status' }
    it { is_expected.to include 'cardname' }
  end
end
