# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tools/get_character_tool'
require_relative '../../lib/models'

RSpec.describe HivemindMCP::GetCharacterTool do
  let(:tool) { described_class.new }
  let(:fact) { double(fact: 'Some fact') }

  it 'uses ActiveRecord when DB is configured' do
    # stub_const('ENV', ENV.to_hash.merge('HIVEMIND_DB_DATABASE' => 'hivemind_test'))
    allow(HivemindMCP::DB).to receive(:configured?).and_return(true)

    fake = double(HivemindMCP::Character,
                  id: '11111111-2222-3333-4444-555555555555',
                  name: 'Trinity',
                  alternate_names: [ 'Hack Queen' ],
                  tags: [ 'ops' ],
                  facts: [ fact ],
                  public: true)

    expect(HivemindMCP::Character).to receive(:find_by).with(id: '1').and_return(fake)

    result = tool.call(id: 'gid://hivemind/Character/1')
    expect(result).to be_a(String)
    expect(result).to include('ID: gid://hivemind/Character/11111111-2222-3333-4444-555555555555')
    expect(result).to include('Name: Trinity')
    expect(result).to include('Alternate Names: Hack Queen')
    expect(result).to include('Tags: ops')
    expect(result).to include('Public: Yes')
    expect(result).to include('- Some fact')
  end
end
