//
//  CourseDetails.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 10/18/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import MapKit


var crossTownClassicCoordinates = [CLLocationCoordinate2D(latitude: 41.830943981185563, longitude: -87.63381507425423), CLLocationCoordinate2D(latitude: 41.830952949821942, longitude: -87.632306080225945), CLLocationCoordinate2D(latitude: 41.830912968143821, longitude: -87.632214046929093), CLLocationCoordinate2D(latitude: 41.83090592734515, longitude: -87.630643026817253), CLLocationCoordinate2D(latitude: 41.830928977578871, longitude: -87.630029052409839), CLLocationCoordinate2D(latitude: 41.830980945378542, longitude: -87.629926038819804), CLLocationCoordinate2D(latitude: 41.830982957035296, longitude: -87.629893014121308), CLLocationCoordinate2D(latitude: 41.830988992005601, longitude: -87.629822019401445),CLLocationCoordinate2D(latitude: 41.83123198337853, longitude: -87.62983107185687), CLLocationCoordinate2D(latitude: 41.831285962834954, longitude: -87.62983400552298), CLLocationCoordinate2D(latitude: 41.831649988889687, longitude: -87.629931067961707), CLLocationCoordinate2D(latitude: 41.831826930865638, longitude: -87.629959063518299), CLLocationCoordinate2D(latitude: 41.832778947427855, longitude: -87.630101052958082),CLLocationCoordinate2D(latitude: 41.833975967019789, longitude: -87.630218064326357), CLLocationCoordinate2D(latitude: 41.834394978359349, longitude: -87.63031705460287),CLLocationCoordinate2D(latitude: 41.836941987276077, longitude: -87.630376063201183), CLLocationCoordinate2D(latitude: 41.837646989151821, longitude: -87.630362065422901),CLLocationCoordinate2D(latitude: 41.837700968608253, longitude: -87.630362065422901),CLLocationCoordinate2D(latitude: 41.837900960817933, longitude: -87.630404058757776), CLLocationCoordinate2D(latitude: 41.838778965175145, longitude: -87.630434065971144), CLLocationCoordinate2D(latitude: 41.83965596370399, longitude: -87.630454014900693), CLLocationCoordinate2D(latitude: 41.841032942757003, longitude: -87.630441022950777), CLLocationCoordinate2D(latitude: 41.841801982372992, longitude: -87.630493074569472), CLLocationCoordinate2D(latitude: 41.842493992298827, longitude: -87.630605056795886), CLLocationCoordinate2D(latitude: 41.842797920107841, longitude: -87.630747046235669), CLLocationCoordinate2D(latitude: 41.844178922474377, longitude: -87.631040077570617), CLLocationCoordinate2D(latitude: 41.844232985749841, longitude: -87.631050052035391), CLLocationCoordinate2D(latitude: 41.844675969332457, longitude: -87.63100504121536), CLLocationCoordinate2D(latitude: 41.845254991203532, longitude: -87.631036054257095), CLLocationCoordinate2D(latitude: 41.845569983124719, longitude: -87.631007052872121), CLLocationCoordinate2D(latitude: 41.8458579853177, longitude: -87.630937063980568), CLLocationCoordinate2D(latitude: 41.846030987799161, longitude: -87.63086104011883), CLLocationCoordinate2D(latitude: 41.846193931996815, longitude: -87.630753081205953), CLLocationCoordinate2D(latitude: 41.846343968063586, longitude: -87.630613019603899), CLLocationCoordinate2D(latitude: 41.846501966938369, longitude: -87.630392072636255), CLLocationCoordinate2D(latitude: 41.84660498052834, longitude: -87.630193002435874), CLLocationCoordinate2D(latitude: 41.846676981076591, longitude: -87.630002062681569), CLLocationCoordinate2D(latitude: 41.846728948876262, longitude: -87.629802070471897), CLLocationCoordinate2D(latitude: 41.846768930554383, longitude: -87.62950602165175), CLLocationCoordinate2D(latitude: 41.846836991608143, longitude: -87.62845903812638), CLLocationCoordinate2D(latitude: 41.846918966621168, longitude: -87.628024017351649),CLLocationCoordinate2D(latitude: 41.846947968006134, longitude: -87.627727046522253), CLLocationCoordinate2D(latitude: 41.846995996311314, longitude: -87.627435021015685), CLLocationCoordinate2D(latitude: 41.847097920253866, longitude: -87.626952055754828), CLLocationCoordinate2D(latitude: 41.847540987655528, longitude: -87.625409031199638), CLLocationCoordinate2D(latitude: 41.847719941288233, longitude: -87.624689025717018), CLLocationCoordinate2D(latitude: 41.847831923514597, longitude: -87.624036075459784), CLLocationCoordinate2D(latitude: 41.847862936556332, longitude: -87.623763076873445), CLLocationCoordinate2D(latitude: 41.847868971526623, longitude: -87.623714042739891), CLLocationCoordinate2D(latitude: 41.847896967083216, longitude: -87.623371055261998), CLLocationCoordinate2D(latitude: 41.847913982346654, longitude: -87.622839055867587), CLLocationCoordinate2D(latitude: 41.84792194515466, longitude: -87.621226042420901),CLLocationCoordinate2D(latitude: 41.847982965409756, longitude: -87.617231059730329), CLLocationCoordinate2D(latitude: 41.848007943481207, longitude: -87.616641057565985),CLLocationCoordinate2D(latitude: 41.848032921552658, longitude: -87.614713052197999), CLLocationCoordinate2D(latitude: 41.848040968179689, longitude: -87.614281048908424), CLLocationCoordinate2D(latitude: 41.84808396734298, longitude: -87.61392205199553), CLLocationCoordinate2D(latitude: 41.848170971497893, longitude: -87.613589038982397), CLLocationCoordinate2D(latitude: 41.848260993137956, longitude: -87.613350070922934), CLLocationCoordinate2D(latitude: 41.848377920687184, longitude: -87.61311101904441), CLLocationCoordinate2D(latitude: 41.848554946482189, longitude: -87.612852018236367), CLLocationCoordinate2D(latitude: 41.848834985867128, longitude: -87.612571056842), CLLocationCoordinate2D(latitude: 41.849058950319886, longitude: -87.612425044088695), CLLocationCoordinate2D(latitude: 41.849090969190001, longitude: -87.612408028825257), CLLocationCoordinate2D(latitude: 41.84912298806011, longitude: -87.61239302521858), CLLocationCoordinate2D(latitude: 41.849265983328223, longitude: -87.612334016620252), CLLocationCoordinate2D(latitude: 41.849506963044384, longitude: -87.612281042992208), CLLocationCoordinate2D(latitude: 41.849773926660426, longitude: -87.612280037163828), CLLocationCoordinate2D(latitude: 41.84993997216224, longitude: -87.612310044377182), CLLocationCoordinate2D(latitude: 41.850536931306124, longitude: -87.612522022708447), CLLocationCoordinate2D(latitude: 41.851915922015898, longitude: -87.61307707233658), CLLocationCoordinate2D(latitude: 41.852578930556781, longitude: -87.613366080357977), CLLocationCoordinate2D(latitude: 41.853126939386108, longitude: -87.613651065065923), CLLocationCoordinate2D(latitude: 41.853852979838841, longitude: -87.614141071125459), CLLocationCoordinate2D(latitude: 41.854073926806436, longitude: -87.614342069163513), CLLocationCoordinate2D(latitude: 41.854227986186736, longitude: -87.614511048331494),CLLocationCoordinate2D(latitude: 41.854937933385372, longitude: -87.61499200193559), CLLocationCoordinate2D(latitude: 41.855602953583002, longitude: -87.615357033818839), CLLocationCoordinate2D(latitude: 41.859711930155754, longitude: -87.617335079148745), CLLocationCoordinate2D(latitude: 41.861470956355319, longitude: -87.618062041610997), CLLocationCoordinate2D(latitude: 41.86258792877198, longitude: -87.618435036302159), CLLocationCoordinate2D(latitude: 41.863151947036378, longitude: -87.618582054883859), CLLocationCoordinate2D(latitude: 41.863928949460394, longitude: -87.618763020173333), CLLocationCoordinate2D(latitude: 41.865909928455963, longitude: -87.619175074533359), CLLocationCoordinate2D(latitude: 41.866301950067275, longitude: -87.619221007362739), CLLocationCoordinate2D(latitude: 41.866602944210165, longitude: -87.619182031512992),CLLocationCoordinate2D(latitude: 41.866752980276935, longitude: -87.619146073148386), CLLocationCoordinate2D(latitude: 41.867049951106303, longitude: -87.61902705012335), CLLocationCoordinate2D(latitude: 41.867321943864205, longitude: -87.618846001014788), CLLocationCoordinate2D(latitude: 41.868754997849464, longitude: -87.617531048044896), CLLocationCoordinate2D(latitude: 41.869093962013721, longitude: -87.617265006438174), CLLocationCoordinate2D(latitude: 41.869429992511861, longitude: -87.617093009785094), CLLocationCoordinate2D(latitude: 41.869606934487827, longitude: -87.617035007015076), CLLocationCoordinate2D(latitude: 41.869872976094477, longitude: -87.616988068357315), CLLocationCoordinate2D(latitude: 41.871081981807933, longitude: -87.616983039215413), CLLocationCoordinate2D(latitude: 41.876802965998642, longitude: -87.617139026433506), CLLocationCoordinate2D(latitude: 41.880936920642831, longitude: -87.617230053901949), CLLocationCoordinate2D(latitude: 41.881367918103933, longitude: -87.617222007274904), CLLocationCoordinate2D(latitude: 41.881766980513923, longitude: -87.617176074445524), CLLocationCoordinate2D(latitude: 41.881939982995377, longitude: -87.617138020605125), CLLocationCoordinate2D(latitude: 41.882128994911909, longitude: -87.617067025885262), CLLocationCoordinate2D(latitude: 41.882285987958312, longitude: -87.616954037830439), CLLocationCoordinate2D(latitude: 41.882438957691193, longitude: -87.616836020633784), CLLocationCoordinate2D(latitude: 41.882567955180988, longitude: -87.616700066164285), CLLocationCoordinate2D(latitude: 41.882690917700515, longitude: -87.616551035925838), CLLocationCoordinate2D(latitude: 41.882967939600348, longitude: -87.616146022364532), CLLocationCoordinate2D(latitude: 41.883437996730194, longitude: -87.614868033587626), CLLocationCoordinate2D(latitude: 41.883603958412991, longitude: -87.614550024181256), CLLocationCoordinate2D(latitude: 41.883701942861073, longitude: -87.614404011428007), CLLocationCoordinate2D(latitude: 41.883807973936207, longitude: -87.614267051130128), CLLocationCoordinate2D(latitude: 41.884042918682091, longitude: -87.61402707724227), CLLocationCoordinate2D(latitude: 41.884300997480757, longitude: -87.613829012870255), CLLocationCoordinate2D(latitude: 41.8844369519502, longitude: -87.61375106117076), CLLocationCoordinate2D(latitude: 41.884576929733164, longitude: -87.613687023430529), CLLocationCoordinate2D(latitude: 41.884879935532794, longitude: -87.613608065902596), CLLocationCoordinate2D(latitude: 41.885249996557818, longitude: -87.613596079781061), CLLocationCoordinate2D(latitude: 41.885482929646969, longitude: -87.61361703453899), CLLocationCoordinate2D(latitude: 41.88744697719811, longitude: -87.61392104616715), CLLocationCoordinate2D(latitude: 41.888024993240833, longitude: -87.613968068643942), CLLocationCoordinate2D(latitude: 41.888065980747342, longitude: -87.613968068643942), CLLocationCoordinate2D(latitude: 41.888104956597076, longitude: -87.613968068643942), CLLocationCoordinate2D(latitude: 41.888777939602726, longitude: -87.613992040887013), CLLocationCoordinate2D(latitude: 41.888820938765996, longitude: -87.613995058372154), CLLocationCoordinate2D(latitude: 41.889559971168644, longitude: -87.614010061978831), CLLocationCoordinate2D(latitude: 41.89037695527076, longitude: -87.613940073087349), CLLocationCoordinate2D(latitude: 41.890903925523169, longitude: -87.613925069480672), CLLocationCoordinate2D(latitude: 41.89235994592309, longitude: -87.613976031451955), CLLocationCoordinate2D(latitude: 41.892659934237599, longitude: -87.614005032836928), CLLocationCoordinate2D(latitude: 41.892879959195838, longitude: -87.61405004365696), CLLocationCoordinate2D(latitude: 41.893199980258935, longitude: -87.614184070288729), CLLocationCoordinate2D(latitude: 41.89352192915976, longitude: -87.614394036963233), CLLocationCoordinate2D(latitude: 41.894362969323986, longitude: -87.615021003320592), CLLocationCoordinate2D(latitude: 41.895035952329643, longitude: -87.615491060450552), CLLocationCoordinate2D(latitude: 41.897024977952235, longitude: -87.616820011198698), CLLocationCoordinate2D(latitude: 41.899256994947784, longitude: -87.618344008833716), CLLocationCoordinate2D(latitude: 41.900828937068582, longitude: -87.619368025944425), CLLocationCoordinate2D(latitude: 41.901025995612144, longitude: -87.619546057567831), CLLocationCoordinate2D(latitude: 41.901173936203115, longitude: -87.619766082526141), CLLocationCoordinate2D(latitude: 41.901233950629837, longitude: -87.619886027560526), CLLocationCoordinate2D(latitude: 41.90132196061311, longitude: -87.620157014490132), CLLocationCoordinate2D(latitude: 41.901371916756027, longitude: -87.620491033331632), CLLocationCoordinate2D(latitude: 41.90145498141645, longitude: -87.621709007681773), CLLocationCoordinate2D(latitude: 41.901516923680902, longitude: -87.62209700597964), CLLocationCoordinate2D(latitude: 41.901626978069537, longitude: -87.622499002055861), CLLocationCoordinate2D(latitude: 41.901791933923953, longitude: -87.622900076122662), CLLocationCoordinate2D(latitude: 41.901994943618767, longitude: -87.623256055550485), CLLocationCoordinate2D(latitude: 41.902200970798724, longitude: -87.623517068015303), CLLocationCoordinate2D(latitude: 41.902329968288541, longitude: -87.623652016656365), CLLocationCoordinate2D(latitude: 41.902600955218062, longitude: -87.623873047443055), CLLocationCoordinate2D(latitude: 41.90274495631455, longitude: -87.623964074911541), CLLocationCoordinate2D(latitude: 41.903045950457454, longitude: -87.624102041037759), CLLocationCoordinate2D(latitude: 41.904014982283122, longitude: -87.624404041009129), CLLocationCoordinate2D(latitude: 41.904692994430654, longitude: -87.624584000470222), CLLocationCoordinate2D(latitude: 41.908816974610083, longitude: -87.62560407808644), CLLocationCoordinate2D(latitude: 41.909086955711238, longitude: -87.625664008694173), CLLocationCoordinate2D(latitude: 41.90978994593025, longitude: -87.625723017292501), CLLocationCoordinate2D(latitude: 41.911626923829317, longitude: -87.625802058639394), CLLocationCoordinate2D(latitude: 41.911934958770864, longitude: -87.625847069459425), CLLocationCoordinate2D(latitude: 41.912252968177199, longitude: -87.625928038644147), CLLocationCoordinate2D(latitude: 41.91249495372174, longitude: -87.626030046405717), CLLocationCoordinate2D(latitude: 41.915226951241493, longitude: -87.627382047387641), CLLocationCoordinate2D(latitude: 41.916404943913214, longitude: -87.628024017351649), CLLocationCoordinate2D(latitude: 41.917284959927187, longitude: -87.62843607171169), CLLocationCoordinate2D(latitude: 41.918178973719456, longitude: -87.628802025604273), CLLocationCoordinate2D(latitude: 41.919087991118424, longitude: -87.62911307803104), CLLocationCoordinate2D(latitude: 41.919546984136105, longitude: -87.629246015015312), CLLocationCoordinate2D(latitude: 41.921376921236508, longitude: -87.62967407881041), CLLocationCoordinate2D(latitude: 41.924172956496477, longitude: -87.630554011005572), CLLocationCoordinate2D(latitude: 41.927707940340049, longitude: -87.631675006735975), CLLocationCoordinate2D(latitude: 41.928195934742675, longitude: -87.63182101948928), CLLocationCoordinate2D(latitude: 41.928686946630492, longitude: -87.631923027250878), CLLocationCoordinate2D(latitude: 41.928957933560021, longitude: -87.631955046120993), CLLocationCoordinate2D(latitude: 41.929431930184364, longitude: -87.631977006707359), CLLocationCoordinate2D(latitude: 41.933166990056627, longitude: -87.631901066664568), CLLocationCoordinate2D(latitude: 41.933945920318365, longitude: -87.632043056104337), CLLocationCoordinate2D(latitude: 41.934297960251577, longitude: -87.632139028895651), CLLocationCoordinate2D(latitude: 41.934706997126327, longitude: -87.632288059134126), CLLocationCoordinate2D(latitude: 41.93540797568857, longitude: -87.63262400581327), CLLocationCoordinate2D(latitude: 41.935745934024446, longitude: -87.632854005236368), CLLocationCoordinate2D(latitude: 41.936195958405712, longitude: -87.633198082361659), CLLocationCoordinate2D(latitude: 41.936599966138601, longitude: -87.633570071224469), CLLocationCoordinate2D(latitude: 41.936986958608017, longitude: -87.633986065078986), CLLocationCoordinate2D(latitude: 41.937282923609011, longitude: -87.634357048113429), CLLocationCoordinate2D(latitude: 41.938848998397582, longitude: -87.636479010720848), CLLocationCoordinate2D(latitude: 41.939376974478357, longitude: -87.637179067273891), CLLocationCoordinate2D(latitude: 41.939879972487681, longitude: -87.637741073881671), CLLocationCoordinate2D(latitude: 41.940365955233574, longitude: -87.638180034150878), CLLocationCoordinate2D(latitude: 41.941295927390456, longitude: -87.63892107821043), CLLocationCoordinate2D(latitude: 41.941829938441501, longitude: -87.639248056253223), CLLocationCoordinate2D(latitude: 41.944335959851742, longitude: -87.640599051406753), CLLocationCoordinate2D(latitude: 41.945436922833316, longitude: -87.641157034700996), CLLocationCoordinate2D(latitude: 41.947190919890993, longitude: -87.642162024891491), CLLocationCoordinate2D(latitude: 41.948935948312275, longitude: -87.643173050052269), CLLocationCoordinate2D(latitude: 41.950736967846751, longitude: -87.644285077146321), CLLocationCoordinate2D(latitude: 41.9509149994701, longitude: -87.644380044109255), CLLocationCoordinate2D(latitude: 41.951269973069422, longitude: -87.644517004407135), CLLocationCoordinate2D(latitude: 41.951632993295782, longitude: -87.644591016612125), CLLocationCoordinate2D(latitude: 41.951838936656706, longitude: -87.644601074895931), CLLocationCoordinate2D(latitude: 41.952631948515766, longitude: -87.644571067682591), CLLocationCoordinate2D(latitude: 41.95271291770041, longitude: -87.644570061854196), CLLocationCoordinate2D(latitude: 41.953196972608573, longitude: -87.644434023565722), CLLocationCoordinate2D(latitude: 41.953813964501016, longitude: -87.644297063267842), CLLocationCoordinate2D(latitude: 41.954187965020537, longitude: -87.644229002214104), CLLocationCoordinate2D(latitude: 41.954655926674604, longitude: -87.644172005272537), CLLocationCoordinate2D(latitude: 41.954685933887944, longitude: -87.644172005272537), CLLocationCoordinate2D(latitude: 41.954678976908319, longitude: -87.644543072125984), CLLocationCoordinate2D(latitude: 41.954677971079938, longitude: -87.644597051582409), CLLocationCoordinate2D(latitude: 41.954656932502971, longitude: -87.645226029596586), CLLocationCoordinate2D(latitude: 41.954587949439876, longitude: -87.649681011133268), CLLocationCoordinate2D(latitude: 41.95449398830533, longitude: -87.654462048703451), CLLocationCoordinate2D(latitude: 41.954492982476957, longitude: -87.654535055080075), CLLocationCoordinate2D(latitude: 41.953545995056622, longitude: -87.654486020946521), CLLocationCoordinate2D(latitude: 41.949106939136968, longitude: -87.654360040941825), CLLocationCoordinate2D(latitude: 41.949053965508945, longitude: -87.654359035113416), CLLocationCoordinate2D(latitude: 41.949042985215783, longitude: -87.655309040019119)]




