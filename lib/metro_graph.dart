import 'package:latlong2/latlong.dart';

class MetroStation {
  final String id;
  final String nameEn;
  final String nameAr;
  final List<String> lines;
  final LatLng location;

  const MetroStation({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.lines,
    required this.location,
  });
}

class MetroGraph {
  static final Map<String, MetroStation> stations = {
    'helwan': const MetroStation(id: 'helwan', nameEn: 'Helwan', nameAr: 'حلوان', lines: ['1'], location: LatLng(29.849, 31.334)),
    'ain_helwan': const MetroStation(id: 'ain_helwan', nameEn: 'Ain Helwan', nameAr: 'عين حلوان', lines: ['1'], location: LatLng(29.8602, 31.3264)),
    'helwan_university': const MetroStation(id: 'helwan_university', nameEn: 'Helwan University', nameAr: 'جامعة حلوان', lines: ['1'], location: LatLng(29.8714, 31.3188)),
    'wadi_hof': const MetroStation(id: 'wadi_hof', nameEn: 'Wadi Hof', nameAr: 'وادي حوف', lines: ['1'], location: LatLng(29.8826, 31.3112)),
    'hadayek_helwan': const MetroStation(id: 'hadayek_helwan', nameEn: 'Hadayek Helwan', nameAr: 'حدائق حلوان', lines: ['1'], location: LatLng(29.8938, 31.3036)),
    'el_maasara': const MetroStation(id: 'el_maasara', nameEn: 'El-Maasara', nameAr: 'المعصرة', lines: ['1'], location: LatLng(29.905, 31.296)),
    'tura_el_asmant': const MetroStation(id: 'tura_el_asmant', nameEn: 'Tura El-Asmant', nameAr: 'طرة الأسمنت', lines: ['1'], location: LatLng(29.9162, 31.2884)),
    'kozzika': const MetroStation(id: 'kozzika', nameEn: 'Kozzika', nameAr: 'كوتسيكا', lines: ['1'], location: LatLng(29.9274, 31.2808)),
    'tura_el_balad': const MetroStation(id: 'tura_el_balad', nameEn: 'Tura El-Balad', nameAr: 'طرة البلد', lines: ['1'], location: LatLng(29.9386, 31.2732)),
    'sakanat_el_maadi': const MetroStation(id: 'sakanat_el_maadi', nameEn: 'Sakanat El-Maadi', nameAr: 'ثكنات المعادي', lines: ['1'], location: LatLng(29.9498, 31.2656)),
    'maadi': const MetroStation(id: 'maadi', nameEn: 'Maadi', nameAr: 'المعادي', lines: ['1'], location: LatLng(29.961, 31.258)),
    'hadayek_el_maadi': const MetroStation(id: 'hadayek_el_maadi', nameEn: 'Hadayek El-Maadi', nameAr: 'حدائق المعادي', lines: ['1'], location: LatLng(29.9725, 31.25433)),
    'dar_el_salam': const MetroStation(id: 'dar_el_salam', nameEn: 'Dar El-Salam', nameAr: 'دار السلام', lines: ['1'], location: LatLng(29.984, 31.25067)),
    'el_zahraa': const MetroStation(id: 'el_zahraa', nameEn: 'El-Zahraa', nameAr: 'الزهراء', lines: ['1'], location: LatLng(29.9955, 31.247)),
    'mar_girgis': const MetroStation(id: 'mar_girgis', nameEn: 'Mar Girgis', nameAr: 'مار جرجس', lines: ['1'], location: LatLng(30.007, 31.24333)),
    'el_malek_el_saleh': const MetroStation(id: 'el_malek_el_saleh', nameEn: 'El-Malek El-Saleh', nameAr: 'الملك الصالح', lines: ['1'], location: LatLng(30.0185, 31.23967)),
    'al_sayeda_zeinab': const MetroStation(id: 'al_sayeda_zeinab', nameEn: 'Al-Sayeda Zeinab', nameAr: 'السيدة زينب', lines: ['1'], location: LatLng(30.03, 31.236)),
    'saad_zaghloul': const MetroStation(id: 'saad_zaghloul', nameEn: 'Saad Zaghloul', nameAr: 'سعد زغلول', lines: ['1'], location: LatLng(30.037, 31.2355)),
    'sadat': const MetroStation(id: 'sadat', nameEn: 'Sadat', nameAr: 'السادات', lines: ['1', '2'], location: LatLng(30.044, 31.235)),
    'gamal_abdalnasser': const MetroStation(id: 'gamal_abdalnasser', nameEn: 'Gamal AbdAlNasser', nameAr: 'جمال عبدالناصر', lines: ['1', '3'], location: LatLng(30.052, 31.238)),
    'orabi': const MetroStation(id: 'orabi', nameEn: 'Orabi', nameAr: 'عرابي', lines: ['1'], location: LatLng(30.0565, 31.242)),
    'al_shohadaa': const MetroStation(id: 'al_shohadaa', nameEn: 'Al-Shohadaa', nameAr: 'الشهداء', lines: ['1', '2'], location: LatLng(30.061, 31.246)),
    'ghamra': const MetroStation(id: 'ghamra', nameEn: 'Ghamra', nameAr: 'غمرة', lines: ['1'], location: LatLng(30.06725, 31.258)),
    'el_demerdash': const MetroStation(id: 'el_demerdash', nameEn: 'El-Demerdash', nameAr: 'الدمرداش', lines: ['1'], location: LatLng(30.0735, 31.27)),
    'manshiet_el_sadr': const MetroStation(id: 'manshiet_el_sadr', nameEn: 'Manshiet El-Sadr', nameAr: 'منشية الصدر', lines: ['1'], location: LatLng(30.07975, 31.282)),
    'kobri_el_qobba': const MetroStation(id: 'kobri_el_qobba', nameEn: 'Kobri El-Qobba', nameAr: 'كوبري القبة', lines: ['1'], location: LatLng(30.086, 31.294)),
    'hammamat_el_qobba': const MetroStation(id: 'hammamat_el_qobba', nameEn: 'Hammamat El-Qobba', nameAr: 'حمامات القبة', lines: ['1'], location: LatLng(30.093, 31.29817)),
    'saray_el_qobba': const MetroStation(id: 'saray_el_qobba', nameEn: 'Saray El-Qobba', nameAr: 'سراي القبة', lines: ['1'], location: LatLng(30.1, 31.30233)),
    'hadayek_el_zaitoun': const MetroStation(id: 'hadayek_el_zaitoun', nameEn: 'Hadayek El-Zaitoun', nameAr: 'حدائق الزيتون', lines: ['1'], location: LatLng(30.107, 31.3065)),
    'helmeyet_el_zaitoun': const MetroStation(id: 'helmeyet_el_zaitoun', nameEn: 'Helmeyet El-Zaitoun', nameAr: 'حلمية الزيتون', lines: ['1'], location: LatLng(30.114, 31.31067)),
    'el_matareyya': const MetroStation(id: 'el_matareyya', nameEn: 'El-Matareyya', nameAr: 'المطرية', lines: ['1'], location: LatLng(30.121, 31.31483)),
    'ain_shams': const MetroStation(id: 'ain_shams', nameEn: 'Ain Shams', nameAr: 'عين شمس', lines: ['1'], location: LatLng(30.128, 31.319)),
    'ezbet_el_nakhl': const MetroStation(id: 'ezbet_el_nakhl', nameEn: 'Ezbet El-Nakhl', nameAr: 'عزبة النخل', lines: ['1'], location: LatLng(30.13867, 31.32467)),
    'el_marg': const MetroStation(id: 'el_marg', nameEn: 'El-Marg', nameAr: 'المرج', lines: ['1'], location: LatLng(30.14933, 31.33033)),
    'new_el_marg': const MetroStation(id: 'new_el_marg', nameEn: 'New El-Marg', nameAr: 'المرج الجديدة', lines: ['1'], location: LatLng(30.16, 31.336)),
    'el_mounib': const MetroStation(id: 'el_mounib', nameEn: 'El Mounib', nameAr: 'المنيب', lines: ['2'], location: LatLng(29.981, 31.211)),
    'sakiat_mekki': const MetroStation(id: 'sakiat_mekki', nameEn: 'Sakiat Mekki', nameAr: 'ساقية مكي', lines: ['2'], location: LatLng(29.99233, 31.209)),
    'omm_el_misryeen': const MetroStation(id: 'omm_el_misryeen', nameEn: 'Omm El Misryeen', nameAr: 'أم المصريين', lines: ['2'], location: LatLng(30.00367, 31.207)),
    'giza': const MetroStation(id: 'giza', nameEn: 'Giza', nameAr: 'الجيزة', lines: ['2'], location: LatLng(30.015, 31.205)),
    'faisal': const MetroStation(id: 'faisal', nameEn: 'Faisal', nameAr: 'فيصل', lines: ['2'], location: LatLng(30.0205, 31.2025)),
    'cairo_university': const MetroStation(id: 'cairo_university', nameEn: 'Cairo University', nameAr: 'جامعة القاهرة', lines: ['2'], location: LatLng(30.026, 31.2)),
    'el_bohoth': const MetroStation(id: 'el_bohoth', nameEn: 'El Bohoth', nameAr: 'البحوث', lines: ['2'], location: LatLng(30.032, 31.2055)),
    'dokki': const MetroStation(id: 'dokki', nameEn: 'Dokki', nameAr: 'الدقي', lines: ['2'], location: LatLng(30.038, 31.211)),
    'opera': const MetroStation(id: 'opera', nameEn: 'Opera', nameAr: 'الأوبرا', lines: ['2'], location: LatLng(30.041, 31.223)),
    'mohamed_naguib': const MetroStation(id: 'mohamed_naguib', nameEn: 'Mohamed Naguib', nameAr: 'محمد نجيب', lines: ['2'], location: LatLng(30.048, 31.241)),
    'attaba': const MetroStation(id: 'attaba', nameEn: 'Attaba', nameAr: 'العتبة', lines: ['2', '3'], location: LatLng(30.052, 31.247)),
    'massara': const MetroStation(id: 'massara', nameEn: 'Massara', nameAr: 'مسرة', lines: ['2'], location: LatLng(30.06971, 31.24557)),
    'road_el_farag': const MetroStation(id: 'road_el_farag', nameEn: 'Road El-Farag', nameAr: 'روض الفرج', lines: ['2'], location: LatLng(30.07843, 31.24514)),
    'st_teresa': const MetroStation(id: 'st_teresa', nameEn: 'St. Teresa', nameAr: 'سانت تريزا', lines: ['2'], location: LatLng(30.08714, 31.24471)),
    'khalafawy': const MetroStation(id: 'khalafawy', nameEn: 'Khalafawy', nameAr: 'الخلفاوي', lines: ['2'], location: LatLng(30.09586, 31.24429)),
    'mezallat': const MetroStation(id: 'mezallat', nameEn: 'Mezallat', nameAr: 'المظلات', lines: ['2'], location: LatLng(30.10457, 31.24386)),
    'kolleyyet_el_ziraa': const MetroStation(id: 'kolleyyet_el_ziraa', nameEn: 'Kolleyyet El-Ziraa', nameAr: 'كلية الزراعة', lines: ['2'], location: LatLng(30.11329, 31.24343)),
    'shubra_el_kheima': const MetroStation(id: 'shubra_el_kheima', nameEn: 'Shubra El-Kheima', nameAr: 'شبرا الخيمة', lines: ['2'], location: LatLng(30.122, 31.243)),
    'adly_mansour': const MetroStation(id: 'adly_mansour', nameEn: 'Adly Mansour', nameAr: 'عدلي منصور', lines: ['3'], location: LatLng(30.149, 31.42)),
    'el_haykestep': const MetroStation(id: 'el_haykestep', nameEn: 'El Haykestep', nameAr: 'الهايكستب', lines: ['3'], location: LatLng(30.145, 31.4065)),
    'omar_ibn_el_khattab': const MetroStation(id: 'omar_ibn_el_khattab', nameEn: 'Omar Ibn El-Khattab', nameAr: 'عمر بن الخطاب', lines: ['3'], location: LatLng(30.141, 31.393)),
    'qobaa': const MetroStation(id: 'qobaa', nameEn: 'Qobaa', nameAr: 'قباء', lines: ['3'], location: LatLng(30.137, 31.3795)),
    'hesham_barakat': const MetroStation(id: 'hesham_barakat', nameEn: 'Hesham Barakat', nameAr: 'هشام بركات', lines: ['3'], location: LatLng(30.133, 31.366)),
    'el_nozha': const MetroStation(id: 'el_nozha', nameEn: 'El-Nozha', nameAr: 'النزهة', lines: ['3'], location: LatLng(30.129, 31.3525)),
    'nadi_el_shams': const MetroStation(id: 'nadi_el_shams', nameEn: 'Nadi El-Shams', nameAr: 'نادي الشمس', lines: ['3'], location: LatLng(30.125, 31.339)),
    'alf_maskan': const MetroStation(id: 'alf_maskan', nameEn: 'Alf Maskan', nameAr: 'ألف مسكن', lines: ['3'], location: LatLng(30.11757, 31.33343)),
    'heliopolis_square': const MetroStation(id: 'heliopolis_square', nameEn: 'Heliopolis Square', nameAr: 'ميدان هليوبوليس', lines: ['3'], location: LatLng(30.11014, 31.32786)),
    'haroun': const MetroStation(id: 'haroun', nameEn: 'Haroun', nameAr: 'هارون', lines: ['3'], location: LatLng(30.10271, 31.32229)),
    'al_ahram': const MetroStation(id: 'al_ahram', nameEn: 'Al-Ahram', nameAr: 'الأهرام', lines: ['3'], location: LatLng(30.09529, 31.31671)),
    'koleyet_el_banat': const MetroStation(id: 'koleyet_el_banat', nameEn: 'Koleyet El-Banat', nameAr: 'كلية البنات', lines: ['3'], location: LatLng(30.08786, 31.31114)),
    'stadium': const MetroStation(id: 'stadium', nameEn: 'Stadium', nameAr: 'الاستاد', lines: ['3'], location: LatLng(30.08043, 31.30557)),
    'fair_zone': const MetroStation(id: 'fair_zone', nameEn: 'Fair Zone', nameAr: 'أرض المعارض', lines: ['3'], location: LatLng(30.073, 31.3)),
    'abbassia': const MetroStation(id: 'abbassia', nameEn: 'Abbassia', nameAr: 'العباسية', lines: ['3'], location: LatLng(30.0688, 31.2894)),
    'abdou_pasha': const MetroStation(id: 'abdou_pasha', nameEn: 'Abdou Pasha', nameAr: 'عبده باشا', lines: ['3'], location: LatLng(30.0646, 31.2788)),
    'el_geish': const MetroStation(id: 'el_geish', nameEn: 'El-Geish', nameAr: 'الجيش', lines: ['3'], location: LatLng(30.0604, 31.2682)),
    'bab_el_shaaria': const MetroStation(id: 'bab_el_shaaria', nameEn: 'Bab El-Shaaria', nameAr: 'باب الشعرية', lines: ['3'], location: LatLng(30.0562, 31.2576)),
    'maspero': const MetroStation(id: 'maspero', nameEn: 'Maspero', nameAr: 'ماسبيرو', lines: ['3'], location: LatLng(30.0575, 31.23)),
    'safaa_hegazy': const MetroStation(id: 'safaa_hegazy', nameEn: 'Safaa Hegazy', nameAr: 'صفاء حجازي', lines: ['3'], location: LatLng(30.063, 31.222)),
    'kit_kat': const MetroStation(id: 'kit_kat', nameEn: 'Kit Kat', nameAr: 'الكيت كات', lines: ['3'], location: LatLng(30.063, 31.211)),
    'sudan': const MetroStation(id: 'sudan', nameEn: 'Sudan', nameAr: 'السودان', lines: ['3'], location: LatLng(30.07, 31.2058)),
    'imbaba': const MetroStation(id: 'imbaba', nameEn: 'Imbaba', nameAr: 'إمبابة', lines: ['3'], location: LatLng(30.077, 31.2006)),
    'el_bohy': const MetroStation(id: 'el_bohy', nameEn: 'El-Bohy', nameAr: 'البوهي', lines: ['3'], location: LatLng(30.084, 31.1954)),
    'el_qawmia': const MetroStation(id: 'el_qawmia', nameEn: 'El-Qawmia', nameAr: 'القومية', lines: ['3'], location: LatLng(30.091, 31.1902)),
    'ring_road': const MetroStation(id: 'ring_road', nameEn: 'Ring Road', nameAr: 'الطريق الدائري', lines: ['3'], location: LatLng(30.098, 31.185)),
  };

  static final Map<String, List<String>> connections = {
    'helwan': [],
    'ain_helwan': [],
    'helwan_university': [],
    'wadi_hof': [],
    'hadayek_helwan': [],
    'el_maasara': [],
    'tura_el_asmant': [],
    'kozzika': [],
    'tura_el_balad': [],
    'sakanat_el_maadi': [],
    'maadi': [],
    'hadayek_el_maadi': [],
    'dar_el_salam': [],
    'el_zahraa': [],
    'mar_girgis': [],
    'el_malek_el_saleh': [],
    'al_sayeda_zeinab': [],
    'saad_zaghloul': [],
    'sadat': [],
    'gamal_abdalnasser': [],
    'orabi': [],
    'al_shohadaa': [],
    'ghamra': [],
    'el_demerdash': [],
    'manshiet_el_sadr': [],
    'kobri_el_qobba': [],
    'hammamat_el_qobba': [],
    'saray_el_qobba': [],
    'hadayek_el_zaitoun': [],
    'helmeyet_el_zaitoun': [],
    'el_matareyya': [],
    'ain_shams': [],
    'ezbet_el_nakhl': [],
    'el_marg': [],
    'new_el_marg': [],
    'el_mounib': [],
    'sakiat_mekki': [],
    'omm_el_misryeen': [],
    'giza': [],
    'faisal': [],
    'cairo_university': [],
    'el_bohoth': [],
    'dokki': [],
    'opera': [],
    'mohamed_naguib': [],
    'attaba': [],
    'massara': [],
    'road_el_farag': [],
    'st_teresa': [],
    'khalafawy': [],
    'mezallat': [],
    'kolleyyet_el_ziraa': [],
    'shubra_el_kheima': [],
    'adly_mansour': [],
    'el_haykestep': [],
    'omar_ibn_el_khattab': [],
    'qobaa': [],
    'hesham_barakat': [],
    'el_nozha': [],
    'nadi_el_shams': [],
    'alf_maskan': [],
    'heliopolis_square': [],
    'haroun': [],
    'al_ahram': [],
    'koleyet_el_banat': [],
    'stadium': [],
    'fair_zone': [],
    'abbassia': [],
    'abdou_pasha': [],
    'el_geish': [],
    'bab_el_shaaria': [],
    'maspero': [],
    'safaa_hegazy': [],
    'kit_kat': [],
    'sudan': [],
    'imbaba': [],
    'el_bohy': [],
    'el_qawmia': [],
    'ring_road': [],
  };

  static void init() {
    // Build connections
    _connect('helwan', 'ain_helwan');
    _connect('ain_helwan', 'helwan_university');
    _connect('helwan_university', 'wadi_hof');
    _connect('wadi_hof', 'hadayek_helwan');
    _connect('hadayek_helwan', 'el_maasara');
    _connect('el_maasara', 'tura_el_asmant');
    _connect('tura_el_asmant', 'kozzika');
    _connect('kozzika', 'tura_el_balad');
    _connect('tura_el_balad', 'sakanat_el_maadi');
    _connect('sakanat_el_maadi', 'maadi');
    _connect('maadi', 'hadayek_el_maadi');
    _connect('hadayek_el_maadi', 'dar_el_salam');
    _connect('dar_el_salam', 'el_zahraa');
    _connect('el_zahraa', 'mar_girgis');
    _connect('mar_girgis', 'el_malek_el_saleh');
    _connect('el_malek_el_saleh', 'al_sayeda_zeinab');
    _connect('al_sayeda_zeinab', 'saad_zaghloul');
    _connect('saad_zaghloul', 'sadat');
    _connect('sadat', 'gamal_abdalnasser');
    _connect('gamal_abdalnasser', 'orabi');
    _connect('orabi', 'al_shohadaa');
    _connect('al_shohadaa', 'ghamra');
    _connect('ghamra', 'el_demerdash');
    _connect('el_demerdash', 'manshiet_el_sadr');
    _connect('manshiet_el_sadr', 'kobri_el_qobba');
    _connect('kobri_el_qobba', 'hammamat_el_qobba');
    _connect('hammamat_el_qobba', 'saray_el_qobba');
    _connect('saray_el_qobba', 'hadayek_el_zaitoun');
    _connect('hadayek_el_zaitoun', 'helmeyet_el_zaitoun');
    _connect('helmeyet_el_zaitoun', 'el_matareyya');
    _connect('el_matareyya', 'ain_shams');
    _connect('ain_shams', 'ezbet_el_nakhl');
    _connect('ezbet_el_nakhl', 'el_marg');
    _connect('el_marg', 'new_el_marg');
    _connect('el_mounib', 'sakiat_mekki');
    _connect('sakiat_mekki', 'omm_el_misryeen');
    _connect('omm_el_misryeen', 'giza');
    _connect('giza', 'faisal');
    _connect('faisal', 'cairo_university');
    _connect('cairo_university', 'el_bohoth');
    _connect('el_bohoth', 'dokki');
    _connect('dokki', 'opera');
    _connect('opera', 'sadat');
    _connect('sadat', 'mohamed_naguib');
    _connect('mohamed_naguib', 'attaba');
    _connect('attaba', 'al_shohadaa');
    _connect('al_shohadaa', 'massara');
    _connect('massara', 'road_el_farag');
    _connect('road_el_farag', 'st_teresa');
    _connect('st_teresa', 'khalafawy');
    _connect('khalafawy', 'mezallat');
    _connect('mezallat', 'kolleyyet_el_ziraa');
    _connect('kolleyyet_el_ziraa', 'shubra_el_kheima');
    _connect('adly_mansour', 'el_haykestep');
    _connect('el_haykestep', 'omar_ibn_el_khattab');
    _connect('omar_ibn_el_khattab', 'qobaa');
    _connect('qobaa', 'hesham_barakat');
    _connect('hesham_barakat', 'el_nozha');
    _connect('el_nozha', 'nadi_el_shams');
    _connect('nadi_el_shams', 'alf_maskan');
    _connect('alf_maskan', 'heliopolis_square');
    _connect('heliopolis_square', 'haroun');
    _connect('haroun', 'al_ahram');
    _connect('al_ahram', 'koleyet_el_banat');
    _connect('koleyet_el_banat', 'stadium');
    _connect('stadium', 'fair_zone');
    _connect('fair_zone', 'abbassia');
    _connect('abbassia', 'abdou_pasha');
    _connect('abdou_pasha', 'el_geish');
    _connect('el_geish', 'bab_el_shaaria');
    _connect('bab_el_shaaria', 'attaba');
    _connect('attaba', 'gamal_abdalnasser');
    _connect('gamal_abdalnasser', 'maspero');
    _connect('maspero', 'safaa_hegazy');
    _connect('safaa_hegazy', 'kit_kat');
    _connect('kit_kat', 'sudan');
    _connect('sudan', 'imbaba');
    _connect('imbaba', 'el_bohy');
    _connect('el_bohy', 'el_qawmia');
    _connect('el_qawmia', 'ring_road');
  }

  static void _connect(String a, String b) {
    if (!connections[a]!.contains(b)) connections[a]!.add(b);
    if (!connections[b]!.contains(a)) connections[b]!.add(a);
  }
}
