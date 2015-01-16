describe Card::Set::Type::Markdown do
  describe 'core view' do
    it 'renders markdown' do
      core_view = render_card :core, {:content=>"### Header\n`puts Hello World!`", :type=>'markdown'}
      expect(core_view.gsub("\n",'')).to eq '<h3 id="header">Header</h3><p><code>puts Hello World!</code></p>'
    end
  end
end