%{
(women men other serious monopoly agemin agemax) = \
    `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                        OPTIONAL MATCH (u)-[:LF]->(w:gender {name: ''Woman''})
                        OPTIONAL MATCH (u)-[:LF]->(m:gender {name: ''Man''})
                        OPTIONAL MATCH (u)-[:LF]->(o:gender {name: ''Other''})
                        RETURN exists(w), exists(m), exists(o), u.serious, u.monopoly, u.agemin, u.agemax'}

for (g = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:LF]->(g:gender) RETURN g.name'}) {
    $g = checked
}

for (var = women men other serious monopoly agemin agemax) {
    if {! isempty $(p_$var)} {
        $var = $(p_$var)
    }
    $var = `{redis_html $$var}
    if {isempty $$var} {
        $var = ()
    }
}
%}

<link rel="stylesheet" href="/css/quill.css">

<div class="box" style="margin-top: 0">
    <h1>Matchmaking</h1>

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <label>I want to meet...</label><br />
        <input id="women" type="checkbox" name="Women" value="true" %(`{if {~ $women true} { echo checked }}%)>
        <label for="women">Women</label><br />
        <input id="men" type="checkbox" name="Men" value="true" %(`{if {~ $men true} { echo checked }}%)>
        <label for="men">Men</label><br />
        <input id="other" type="checkbox" name="Other" value="true" %(`{if {~ $other true} { echo checked }}%)>
        <label for="other">Other genders</label><br />

        <label for="agemin">Age range</label>
        <select name="agemin" style="width: auto; margin-top: 12px">
            <option hidden disabled selected value></option>
            <option value="18" %(`{if {~ $agemin 18} { echo 'selected' }}%)>18</option>
            <option value="19" %(`{if {~ $agemin 19} { echo 'selected' }}%)>19</option>
            <option value="20" %(`{if {~ $agemin 20} { echo 'selected' }}%)>20</option>
            <option value="21" %(`{if {~ $agemin 21} { echo 'selected' }}%)>21</option>
            <option value="22" %(`{if {~ $agemin 22} { echo 'selected' }}%)>22</option>
            <option value="23" %(`{if {~ $agemin 23} { echo 'selected' }}%)>23</option>
            <option value="24" %(`{if {~ $agemin 24} { echo 'selected' }}%)>24</option>
            <option value="25" %(`{if {~ $agemin 25} { echo 'selected' }}%)>25</option>
            <option value="26" %(`{if {~ $agemin 26} { echo 'selected' }}%)>26</option>
            <option value="27" %(`{if {~ $agemin 27} { echo 'selected' }}%)>27</option>
            <option value="28" %(`{if {~ $agemin 28} { echo 'selected' }}%)>28</option>
            <option value="29" %(`{if {~ $agemin 29} { echo 'selected' }}%)>29</option>
            <option value="30" %(`{if {~ $agemin 30} { echo 'selected' }}%)>30</option>
            <option value="31" %(`{if {~ $agemin 31} { echo 'selected' }}%)>31</option>
            <option value="32" %(`{if {~ $agemin 32} { echo 'selected' }}%)>32</option>
            <option value="33" %(`{if {~ $agemin 33} { echo 'selected' }}%)>33</option>
            <option value="34" %(`{if {~ $agemin 34} { echo 'selected' }}%)>34</option>
            <option value="35" %(`{if {~ $agemin 35} { echo 'selected' }}%)>35</option>
            <option value="36" %(`{if {~ $agemin 36} { echo 'selected' }}%)>36</option>
            <option value="37" %(`{if {~ $agemin 37} { echo 'selected' }}%)>37</option>
            <option value="38" %(`{if {~ $agemin 38} { echo 'selected' }}%)>38</option>
            <option value="39" %(`{if {~ $agemin 39} { echo 'selected' }}%)>39</option>
            <option value="40" %(`{if {~ $agemin 40} { echo 'selected' }}%)>40</option>
            <option value="41" %(`{if {~ $agemin 41} { echo 'selected' }}%)>41</option>
            <option value="42" %(`{if {~ $agemin 42} { echo 'selected' }}%)>42</option>
            <option value="43" %(`{if {~ $agemin 43} { echo 'selected' }}%)>43</option>
            <option value="44" %(`{if {~ $agemin 44} { echo 'selected' }}%)>44</option>
            <option value="45" %(`{if {~ $agemin 45} { echo 'selected' }}%)>45</option>
            <option value="46" %(`{if {~ $agemin 46} { echo 'selected' }}%)>46</option>
            <option value="47" %(`{if {~ $agemin 47} { echo 'selected' }}%)>47</option>
            <option value="48" %(`{if {~ $agemin 48} { echo 'selected' }}%)>48</option>
            <option value="49" %(`{if {~ $agemin 49} { echo 'selected' }}%)>49</option>
            <option value="50" %(`{if {~ $agemin 50} { echo 'selected' }}%)>50</option>
            <option value="51" %(`{if {~ $agemin 51} { echo 'selected' }}%)>51</option>
            <option value="52" %(`{if {~ $agemin 52} { echo 'selected' }}%)>52</option>
            <option value="53" %(`{if {~ $agemin 53} { echo 'selected' }}%)>53</option>
            <option value="54" %(`{if {~ $agemin 54} { echo 'selected' }}%)>54</option>
            <option value="55" %(`{if {~ $agemin 55} { echo 'selected' }}%)>55</option>
            <option value="56" %(`{if {~ $agemin 56} { echo 'selected' }}%)>56</option>
            <option value="57" %(`{if {~ $agemin 57} { echo 'selected' }}%)>57</option>
            <option value="58" %(`{if {~ $agemin 58} { echo 'selected' }}%)>58</option>
            <option value="59" %(`{if {~ $agemin 59} { echo 'selected' }}%)>59</option>
            <option value="60" %(`{if {~ $agemin 60} { echo 'selected' }}%)>60</option>
            <option value="61" %(`{if {~ $agemin 61} { echo 'selected' }}%)>61</option>
            <option value="62" %(`{if {~ $agemin 62} { echo 'selected' }}%)>62</option>
            <option value="63" %(`{if {~ $agemin 63} { echo 'selected' }}%)>63</option>
            <option value="64" %(`{if {~ $agemin 64} { echo 'selected' }}%)>64</option>
            <option value="65" %(`{if {~ $agemin 65} { echo 'selected' }}%)>65</option>
            <option value="66" %(`{if {~ $agemin 66} { echo 'selected' }}%)>66</option>
            <option value="67" %(`{if {~ $agemin 67} { echo 'selected' }}%)>67</option>
            <option value="68" %(`{if {~ $agemin 68} { echo 'selected' }}%)>68</option>
            <option value="69" %(`{if {~ $agemin 69} { echo 'selected' }}%)>69</option>
            <option value="70" %(`{if {~ $agemin 70} { echo 'selected' }}%)>70</option>
            <option value="71" %(`{if {~ $agemin 71} { echo 'selected' }}%)>71</option>
            <option value="72" %(`{if {~ $agemin 72} { echo 'selected' }}%)>72</option>
            <option value="73" %(`{if {~ $agemin 73} { echo 'selected' }}%)>73</option>
            <option value="74" %(`{if {~ $agemin 74} { echo 'selected' }}%)>74</option>
            <option value="75" %(`{if {~ $agemin 75} { echo 'selected' }}%)>75</option>
            <option value="76" %(`{if {~ $agemin 76} { echo 'selected' }}%)>76</option>
            <option value="77" %(`{if {~ $agemin 77} { echo 'selected' }}%)>77</option>
            <option value="78" %(`{if {~ $agemin 78} { echo 'selected' }}%)>78</option>
            <option value="79" %(`{if {~ $agemin 79} { echo 'selected' }}%)>79</option>
            <option value="80" %(`{if {~ $agemin 80} { echo 'selected' }}%)>80</option>
            <option value="81" %(`{if {~ $agemin 81} { echo 'selected' }}%)>81</option>
            <option value="82" %(`{if {~ $agemin 82} { echo 'selected' }}%)>82</option>
            <option value="83" %(`{if {~ $agemin 83} { echo 'selected' }}%)>83</option>
            <option value="84" %(`{if {~ $agemin 84} { echo 'selected' }}%)>84</option>
            <option value="85" %(`{if {~ $agemin 85} { echo 'selected' }}%)>85</option>
            <option value="86" %(`{if {~ $agemin 86} { echo 'selected' }}%)>86</option>
            <option value="87" %(`{if {~ $agemin 87} { echo 'selected' }}%)>87</option>
            <option value="88" %(`{if {~ $agemin 88} { echo 'selected' }}%)>88</option>
            <option value="89" %(`{if {~ $agemin 89} { echo 'selected' }}%)>89</option>
            <option value="90" %(`{if {~ $agemin 90} { echo 'selected' }}%)>90</option>
            <option value="91" %(`{if {~ $agemin 91} { echo 'selected' }}%)>91</option>
            <option value="92" %(`{if {~ $agemin 92} { echo 'selected' }}%)>92</option>
            <option value="93" %(`{if {~ $agemin 93} { echo 'selected' }}%)>93</option>
            <option value="94" %(`{if {~ $agemin 94} { echo 'selected' }}%)>94</option>
            <option value="95" %(`{if {~ $agemin 95} { echo 'selected' }}%)>95</option>
            <option value="96" %(`{if {~ $agemin 96} { echo 'selected' }}%)>96</option>
            <option value="97" %(`{if {~ $agemin 97} { echo 'selected' }}%)>97</option>
            <option value="98" %(`{if {~ $agemin 98} { echo 'selected' }}%)>98</option>
            <option value="99" %(`{if {~ $agemin 99} { echo 'selected' }}%)>99</option>
            <option value="100" %(`{if {~ $agemin 100} { echo 'selected' }}%)>100</option>
            <option value="101" %(`{if {~ $agemin 101} { echo 'selected' }}%)>101</option>
            <option value="102" %(`{if {~ $agemin 102} { echo 'selected' }}%)>102</option>
            <option value="103" %(`{if {~ $agemin 103} { echo 'selected' }}%)>103</option>
            <option value="104" %(`{if {~ $agemin 104} { echo 'selected' }}%)>104</option>
            <option value="105" %(`{if {~ $agemin 105} { echo 'selected' }}%)>105</option>
            <option value="106" %(`{if {~ $agemin 106} { echo 'selected' }}%)>106</option>
            <option value="107" %(`{if {~ $agemin 107} { echo 'selected' }}%)>107</option>
            <option value="108" %(`{if {~ $agemin 108} { echo 'selected' }}%)>108</option>
            <option value="109" %(`{if {~ $agemin 109} { echo 'selected' }}%)>109</option>
            <option value="110" %(`{if {~ $agemin 110} { echo 'selected' }}%)>110</option>
            <option value="111" %(`{if {~ $agemin 111} { echo 'selected' }}%)>111</option>
            <option value="112" %(`{if {~ $agemin 112} { echo 'selected' }}%)>112</option>
            <option value="113" %(`{if {~ $agemin 113} { echo 'selected' }}%)>113</option>
            <option value="114" %(`{if {~ $agemin 114} { echo 'selected' }}%)>114</option>
            <option value="115" %(`{if {~ $agemin 115} { echo 'selected' }}%)>115</option>
            <option value="116" %(`{if {~ $agemin 116} { echo 'selected' }}%)>116</option>
            <option value="117" %(`{if {~ $agemin 117} { echo 'selected' }}%)>117</option>
            <option value="118" %(`{if {~ $agemin 118} { echo 'selected' }}%)>118</option>
            <option value="119" %(`{if {~ $agemin 119} { echo 'selected' }}%)>119</option>
            <option value="120" %(`{if {~ $agemin 120} { echo 'selected' }}%)>120</option>
            <option value="121" %(`{if {~ $agemin 121} { echo 'selected' }}%)>121</option>
            <option value="122" %(`{if {~ $agemin 122} { echo 'selected' }}%)>122</option>
            <option value="123" %(`{if {~ $agemin 123} { echo 'selected' }}%)>123</option>
            <option value="124" %(`{if {~ $agemin 124} { echo 'selected' }}%)>124</option>
            <option value="125" %(`{if {~ $agemin 125} { echo 'selected' }}%)>125</option>
        </select>
        -
        <select name="agemax" style="width: auto">
            <option hidden disabled selected value></option>
            <option value="18" %(`{if {~ $agemax 18} { echo 'selected' }}%)>18</option>
            <option value="19" %(`{if {~ $agemax 19} { echo 'selected' }}%)>19</option>
            <option value="20" %(`{if {~ $agemax 20} { echo 'selected' }}%)>20</option>
            <option value="21" %(`{if {~ $agemax 21} { echo 'selected' }}%)>21</option>
            <option value="22" %(`{if {~ $agemax 22} { echo 'selected' }}%)>22</option>
            <option value="23" %(`{if {~ $agemax 23} { echo 'selected' }}%)>23</option>
            <option value="24" %(`{if {~ $agemax 24} { echo 'selected' }}%)>24</option>
            <option value="25" %(`{if {~ $agemax 25} { echo 'selected' }}%)>25</option>
            <option value="26" %(`{if {~ $agemax 26} { echo 'selected' }}%)>26</option>
            <option value="27" %(`{if {~ $agemax 27} { echo 'selected' }}%)>27</option>
            <option value="28" %(`{if {~ $agemax 28} { echo 'selected' }}%)>28</option>
            <option value="29" %(`{if {~ $agemax 29} { echo 'selected' }}%)>29</option>
            <option value="30" %(`{if {~ $agemax 30} { echo 'selected' }}%)>30</option>
            <option value="31" %(`{if {~ $agemax 31} { echo 'selected' }}%)>31</option>
            <option value="32" %(`{if {~ $agemax 32} { echo 'selected' }}%)>32</option>
            <option value="33" %(`{if {~ $agemax 33} { echo 'selected' }}%)>33</option>
            <option value="34" %(`{if {~ $agemax 34} { echo 'selected' }}%)>34</option>
            <option value="35" %(`{if {~ $agemax 35} { echo 'selected' }}%)>35</option>
            <option value="36" %(`{if {~ $agemax 36} { echo 'selected' }}%)>36</option>
            <option value="37" %(`{if {~ $agemax 37} { echo 'selected' }}%)>37</option>
            <option value="38" %(`{if {~ $agemax 38} { echo 'selected' }}%)>38</option>
            <option value="39" %(`{if {~ $agemax 39} { echo 'selected' }}%)>39</option>
            <option value="40" %(`{if {~ $agemax 40} { echo 'selected' }}%)>40</option>
            <option value="41" %(`{if {~ $agemax 41} { echo 'selected' }}%)>41</option>
            <option value="42" %(`{if {~ $agemax 42} { echo 'selected' }}%)>42</option>
            <option value="43" %(`{if {~ $agemax 43} { echo 'selected' }}%)>43</option>
            <option value="44" %(`{if {~ $agemax 44} { echo 'selected' }}%)>44</option>
            <option value="45" %(`{if {~ $agemax 45} { echo 'selected' }}%)>45</option>
            <option value="46" %(`{if {~ $agemax 46} { echo 'selected' }}%)>46</option>
            <option value="47" %(`{if {~ $agemax 47} { echo 'selected' }}%)>47</option>
            <option value="48" %(`{if {~ $agemax 48} { echo 'selected' }}%)>48</option>
            <option value="49" %(`{if {~ $agemax 49} { echo 'selected' }}%)>49</option>
            <option value="50" %(`{if {~ $agemax 50} { echo 'selected' }}%)>50</option>
            <option value="51" %(`{if {~ $agemax 51} { echo 'selected' }}%)>51</option>
            <option value="52" %(`{if {~ $agemax 52} { echo 'selected' }}%)>52</option>
            <option value="53" %(`{if {~ $agemax 53} { echo 'selected' }}%)>53</option>
            <option value="54" %(`{if {~ $agemax 54} { echo 'selected' }}%)>54</option>
            <option value="55" %(`{if {~ $agemax 55} { echo 'selected' }}%)>55</option>
            <option value="56" %(`{if {~ $agemax 56} { echo 'selected' }}%)>56</option>
            <option value="57" %(`{if {~ $agemax 57} { echo 'selected' }}%)>57</option>
            <option value="58" %(`{if {~ $agemax 58} { echo 'selected' }}%)>58</option>
            <option value="59" %(`{if {~ $agemax 59} { echo 'selected' }}%)>59</option>
            <option value="60" %(`{if {~ $agemax 60} { echo 'selected' }}%)>60</option>
            <option value="61" %(`{if {~ $agemax 61} { echo 'selected' }}%)>61</option>
            <option value="62" %(`{if {~ $agemax 62} { echo 'selected' }}%)>62</option>
            <option value="63" %(`{if {~ $agemax 63} { echo 'selected' }}%)>63</option>
            <option value="64" %(`{if {~ $agemax 64} { echo 'selected' }}%)>64</option>
            <option value="65" %(`{if {~ $agemax 65} { echo 'selected' }}%)>65</option>
            <option value="66" %(`{if {~ $agemax 66} { echo 'selected' }}%)>66</option>
            <option value="67" %(`{if {~ $agemax 67} { echo 'selected' }}%)>67</option>
            <option value="68" %(`{if {~ $agemax 68} { echo 'selected' }}%)>68</option>
            <option value="69" %(`{if {~ $agemax 69} { echo 'selected' }}%)>69</option>
            <option value="70" %(`{if {~ $agemax 70} { echo 'selected' }}%)>70</option>
            <option value="71" %(`{if {~ $agemax 71} { echo 'selected' }}%)>71</option>
            <option value="72" %(`{if {~ $agemax 72} { echo 'selected' }}%)>72</option>
            <option value="73" %(`{if {~ $agemax 73} { echo 'selected' }}%)>73</option>
            <option value="74" %(`{if {~ $agemax 74} { echo 'selected' }}%)>74</option>
            <option value="75" %(`{if {~ $agemax 75} { echo 'selected' }}%)>75</option>
            <option value="76" %(`{if {~ $agemax 76} { echo 'selected' }}%)>76</option>
            <option value="77" %(`{if {~ $agemax 77} { echo 'selected' }}%)>77</option>
            <option value="78" %(`{if {~ $agemax 78} { echo 'selected' }}%)>78</option>
            <option value="79" %(`{if {~ $agemax 79} { echo 'selected' }}%)>79</option>
            <option value="80" %(`{if {~ $agemax 80} { echo 'selected' }}%)>80</option>
            <option value="81" %(`{if {~ $agemax 81} { echo 'selected' }}%)>81</option>
            <option value="82" %(`{if {~ $agemax 82} { echo 'selected' }}%)>82</option>
            <option value="83" %(`{if {~ $agemax 83} { echo 'selected' }}%)>83</option>
            <option value="84" %(`{if {~ $agemax 84} { echo 'selected' }}%)>84</option>
            <option value="85" %(`{if {~ $agemax 85} { echo 'selected' }}%)>85</option>
            <option value="86" %(`{if {~ $agemax 86} { echo 'selected' }}%)>86</option>
            <option value="87" %(`{if {~ $agemax 87} { echo 'selected' }}%)>87</option>
            <option value="88" %(`{if {~ $agemax 88} { echo 'selected' }}%)>88</option>
            <option value="89" %(`{if {~ $agemax 89} { echo 'selected' }}%)>89</option>
            <option value="90" %(`{if {~ $agemax 90} { echo 'selected' }}%)>90</option>
            <option value="91" %(`{if {~ $agemax 91} { echo 'selected' }}%)>91</option>
            <option value="92" %(`{if {~ $agemax 92} { echo 'selected' }}%)>92</option>
            <option value="93" %(`{if {~ $agemax 93} { echo 'selected' }}%)>93</option>
            <option value="94" %(`{if {~ $agemax 94} { echo 'selected' }}%)>94</option>
            <option value="95" %(`{if {~ $agemax 95} { echo 'selected' }}%)>95</option>
            <option value="96" %(`{if {~ $agemax 96} { echo 'selected' }}%)>96</option>
            <option value="97" %(`{if {~ $agemax 97} { echo 'selected' }}%)>97</option>
            <option value="98" %(`{if {~ $agemax 98} { echo 'selected' }}%)>98</option>
            <option value="99" %(`{if {~ $agemax 99} { echo 'selected' }}%)>99</option>
            <option value="100" %(`{if {~ $agemax 100} { echo 'selected' }}%)>100</option>
            <option value="101" %(`{if {~ $agemax 101} { echo 'selected' }}%)>101</option>
            <option value="102" %(`{if {~ $agemax 102} { echo 'selected' }}%)>102</option>
            <option value="103" %(`{if {~ $agemax 103} { echo 'selected' }}%)>103</option>
            <option value="104" %(`{if {~ $agemax 104} { echo 'selected' }}%)>104</option>
            <option value="105" %(`{if {~ $agemax 105} { echo 'selected' }}%)>105</option>
            <option value="106" %(`{if {~ $agemax 106} { echo 'selected' }}%)>106</option>
            <option value="107" %(`{if {~ $agemax 107} { echo 'selected' }}%)>107</option>
            <option value="108" %(`{if {~ $agemax 108} { echo 'selected' }}%)>108</option>
            <option value="109" %(`{if {~ $agemax 109} { echo 'selected' }}%)>109</option>
            <option value="110" %(`{if {~ $agemax 110} { echo 'selected' }}%)>110</option>
            <option value="111" %(`{if {~ $agemax 111} { echo 'selected' }}%)>111</option>
            <option value="112" %(`{if {~ $agemax 112} { echo 'selected' }}%)>112</option>
            <option value="113" %(`{if {~ $agemax 113} { echo 'selected' }}%)>113</option>
            <option value="114" %(`{if {~ $agemax 114} { echo 'selected' }}%)>114</option>
            <option value="115" %(`{if {~ $agemax 115} { echo 'selected' }}%)>115</option>
            <option value="116" %(`{if {~ $agemax 116} { echo 'selected' }}%)>116</option>
            <option value="117" %(`{if {~ $agemax 117} { echo 'selected' }}%)>117</option>
            <option value="118" %(`{if {~ $agemax 118} { echo 'selected' }}%)>118</option>
            <option value="119" %(`{if {~ $agemax 119} { echo 'selected' }}%)>119</option>
            <option value="120" %(`{if {~ $agemax 120} { echo 'selected' }}%)>120</option>
            <option value="121" %(`{if {~ $agemax 121} { echo 'selected' }}%)>121</option>
            <option value="122" %(`{if {~ $agemax 122} { echo 'selected' }}%)>122</option>
            <option value="123" %(`{if {~ $agemax 123} { echo 'selected' }}%)>123</option>
            <option value="124" %(`{if {~ $agemax 124} { echo 'selected' }}%)>124</option>
            <option value="125" %(`{if {~ $agemax 125} { echo 'selected' }}%)>125</option>
        </select><br /><br />

        <label>Are you open to serious dating?<small> (i.e.&nbsp;meeting&nbsp;in&nbsp;real&nbsp;life)</small></label><br />
        <div class="tags" style="margin: 8px 0 0 -7px">
            <input id="serious_yes" type="radio" name="serious" value="true" %(`{if {~ $serious true} { echo checked }}%)>
            <label for="serious_yes">Yes</label>
            <input id="serious_no" type="radio" name="serious" value="false" %(`{if {~ $serious false} { echo checked }}%)>
            <label for="serious_no">No</label>
        </div>

        <a id="morebtn" class="btn" onclick="toggleMore()" style="font-size: 24px; margin: 65px 0 0 4px">More &#x25BC;</a>
        <div id="more" style="display: none; margin: -8px 0 -23px 0">
            <input id="monogamous" type="radio" name="monopoly" value="Monogamous" %(`{if {~ $monopoly Monogamous} { echo checked }}%)>
            <label for="monogamous">Monogamous</label><br />
            <input id="nonmonogamous" type="radio" name="monopoly" value="Non-monogamous" %(`{if {~ $monopoly Non-monogamous} { echo checked }}%)>
            <label for="nonmonogamous">Non-monogamous</label><br />
            <input id="both" type="radio" name="monopoly" value="Both">
            <label for="both">Open to both</label>
        </div>

%       if {isempty $onboarding} {
            <p>Changes you make to your matchmaking preferences will be applied tomorrow.</p>
%       }

%       if {! isempty $onboarding} {
            <button type="submit" class="btn btn-gradient">Next page</button>
%       } {
            <button type="submit" class="btn btn-gradient">Save</button>
%       }
    </form>
</div>

<style>
    .tags input[type="radio"]:first-child + label {
        border-radius: 15px 0 0 15px;
        transform: translateX(11px);
    }
    .tags input[type="radio"]:nth-child(3) + label {
        border-radius: 0 15px 15px 0;
    }
    .tags input[type="radio"] + label {
        transition: background-color .3s, color .3s, box-shadow .3s !important;
        user-select: none;
    }
    .tags input[type="radio"]:not(:checked) + label {
        position: relative;
        box-shadow: var(--shadow-2);
    }
    .tags input[type="radio"]:not(:checked) + label + input[type="radio"]:not(:checked) + label::after {
        content: "";
        position: absolute;
        width: 17px;
        height: 2.5em;
        background-color: var(--grey);
        transform: translate(-59px, -5px);
    }
</style>

<script type="text/javascript">
    function toggleMore() {
        var more = document.getElementById("more");
        if (more.style.display === "none") {
            more.style.display = "block";
            morebtn.innerHTML = "Less &#x25B2;";
        } else {
            more.style.display = "none";
            morebtn.innerHTML = "More &#x25BC;";
        }
    }
</script>
