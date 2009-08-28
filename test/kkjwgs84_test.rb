require File.join(File.dirname(__FILE__), '..', 'kkjwgs84')
require 'test/unit'

class KKJWGS84Test < Test::Unit::TestCase
  
  def setup
    @coords = {:wgs84 => {:la => 60.167777, :lo => 24.941658}, :kkj_xy => {:p => 6673278, :i => 2552455}, :kkj_lalo => {:la => 60.167606, :lo => 24.944811}}
    @kkj = KKJWGS84.new()
		@acc = 0.00001
  end
    
  def test_kkj_xy_to_wgs84_lalo
    t = @kkj.kkj_xy_to_wgs84_lalo(@coords[:kkj_xy])
    assert_in_delta(@coords[:wgs84][:la],t[:la],@acc)
    assert_in_delta(@coords[:wgs84][:lo],t[:lo],@acc)
  end
  
  def test_wgs84_lalo_to_kkj_xy
    assert_equal(@coords[:kkj_xy],@kkj.wgs84_lalo_to_kkj_xy(@coords[:wgs84]))
  end
  
  def test_kkj_xy_to_kkj_lalo
    t = @kkj.kkj_xy_to_kkj_lalo(@coords[:kkj_xy])
    assert_in_delta(@coords[:kkj_lalo][:la],t[:la],@acc)
    assert_in_delta(@coords[:kkj_lalo][:lo],t[:lo],@acc)
  end
  
  def test_kkj_lalo_to_wgs84_lalo
    t = @kkj.kkj_lalo_to_wgs84_lalo(@coords[:kkj_lalo])
    assert_in_delta(@coords[:wgs84][:la],t[:la],@acc)
    assert_in_delta(@coords[:wgs84][:lo],t[:lo],@acc)
  end
  
  def test_wgs84_lalo_to_kkj_lalo
    t = @kkj.wgs84_lalo_to_kkj_lalo(@coords[:wgs84])
    assert_in_delta(@coords[:kkj_lalo][:la],t[:la],@acc)
    assert_in_delta(@coords[:kkj_lalo][:lo],t[:lo],@acc)
  end
  
end

__END__

Testidata kansalaisen.karttapaikka.fi:stä osoitteelle "Mannerheimintie 10, Helsinki" ja klikkaamalla hutiin.
Luotetaan siihen, että Maanmittauslaitoksella on tarkka algoritmi muunnoksille.

Koordinaatisto							N / lat	E / lon
KKJ peruskoordinaatisto			6673278	2552455
KKJ yhtenäiskoordinaatisto	6674678	3385908
EUREF-FIN (ETRS-TM35FIN)		6671877	385785
KKJ maantieteelliset				60.167606	24.944811
														60° 10.056'	24° 56.689'
														60° 10' 3.382''	24° 56' 41.321''
EUREF-FIN maantieteelliset (~WGS84)	60.167777	24.941658
																		60° 10.067'	24° 56.499'
																		60° 10' 3.996''	24° 56' 29.969''
