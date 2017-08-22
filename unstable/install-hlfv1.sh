ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.12.0
docker tag hyperledger/composer-playground:0.12.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
�  �Y �=�r�r���d��&)W*�}�r&;㝑DR�dy����ZcK�.�Ǟ����D�"4�H�]:�O8U���F�!���@^��Ւ/c[���~�%��� �h�Xk!;��v;(�1a�ac�������a@ ���4.	��)DeI|"FE9���X� �ȷ'@x �ׂ����kî�,ƻ�����vlm���s�s��54�lr �N؛�3�f�а�}j�6�=e�6l��f��l�dG��'T��v��:>I B����!l�?�Y�����6��!Rj���WɔOS{�l>�	~
 p9�D�נ�;�&x7]>z�F.ԡ	�|�E�G0�}�lUo�j12�ll�Tܼ�	�*H��K+���L��j�b�[���n#CL5�e!��]��a��|�<Qi.Q�}�ݮ��f�lC���:r4��Pڴ��X�@�U]1,\G�%Un]�:��B��b��G���F	�t��NFр�s-_���G�9*��a[G61��xq��hy�IEo�m3	(��9lwLD[�a�S,V�kZ��jE�;jXtM���ɧi�=�!*���j�[0�	��t�i�ØНm�|���sN��]��6�z���G9�Aywb�)uanK�S�M�%�|[��O֝�9�	��g�W�c��Bn�-6��=3�Hй�l��iez;p��=!/|��Q7D'����A��x\Y�Q��,���O����́/<��3�."a�Y��v�����_Y<��$����(K���_��ˀ��Gj��A��9س5�g/����aS7I>_&���ieʼ>x�΃~ ��N>ENMI�A��Ks��r�c����p~V��+�_���ˆ9�߁Z6P���փ�`����?Q?�SD!J�	Ř���@W��U�Ue`�F>�$�(BX+~��~2;�V� ڳ.X�O��&�.2q���qAǳ�r,�۱�.t�h��!Vd#��p��m��u��r'W�YŒ'M�FW���{�.Ʀ���`%�C�mb{v�)���3Y��i��l@�$���K}~��Pʚ���ք��:���G;ԡ�|���,����w9���}g�5�0�����e�|�3; ���^�Z�ľǭ%����(�?DÉ�p�����Hˣ}7���Ib�ɰ�f�On��2>\��SM3���7�!�#k�8���,�cQ��I���o)0�qO��@ݳ�>p��-�4�t`�6�"R���Y�a5�/�nT�qq��:w�q��ֳ:S!�q@��:g��;M�$��~�<�𚒴�+@Z~��!a{���O B6l���2W7si�9��.-�^����[�A�S�ڋ�Q��^co� �C�Ĩ�|�g�c�����f��z�	lP�'�	d�|L���D�	���.8#&3oV�:2�����B`gF��e�Y�L�o�.�A�Ɯ|BťO�+V�[��r%�pY%*���Ǿ�$��p����o"� � i.�5�	0�l�O����������:�A�#������u. Է�a�a���,�^!�7���3�3ڿ�e����5 5����c��#D�k^_��D#x��p�r�@�ӱ�V3�
s��H��C���?1%.���e�j��ˆ9�?��q��?����L�hT��/J+�_
�qRz��Gg��ۣ!��9��p��&��h7gÚ�y�M)�A�l��t���	n�+��T9�_��#�M(�&�"�r�2x��ry�Ă���r�j��O�fʕ�^���`6A�0�Yr_� ��ڔ�V���ӓk`��Vp��C���$�R����GDX�R�*o������|!�wP],��<�E�p,�Y�҄��[�ⷁƅ6�z��wB(���3v*��=x�<��x�O�����`�$a��BQ7A���X^��l������@�ui������B��(Q�	\\�]�gՂ���Z�9���������+���}f�;��.V�)����l����������?*
�뿸,������=�Ԩ��i�"b� �بn���<N�f��׹7̱��x��<�~�3.Ģ��ˀ�ǟ�p�7�����H�((��_�v��s(������?� Q$*@�?UV���3�3t�-�� ���+б�^����ҝ0GW�!Խ~�'��@�l�����}��$ݛ�O���6�Ǉ�\�Q��(�S�\A��K�]W��1��V�T.*��+JkФg�\�=�� d���&nƑȆ����g�Ƿ^"?N0b��4�#0��� L�ݝy�L���L��I5�3���D�ZEP_$�����P�M�\�����hl����\����@\��,dGD�<�o|g�G~h�ɳ��V������Ә�BX���!�{���ܻq����k�u>i�ok��9p������	��%E^�X
<��/'d��F���H�?<<x��
NdN�G��*�����R������O���.�k�������򉬏��.�4��l7 ��N��s@Z�Y&�~p��:��rZg�Ǡ���JTfI �R�q�@д�� 5��{��˂�n�k�'�7s�f2E�ܼ$��%0N��M�~f� D�)$��1��c��̿�	}nL�d���Vc&5��tS�g3d�ˆ1Ua"�tSg��<���+dצ��9iʢ)�e�� �܀#j���wui�c�	2a"+�H}�����{5ci�:�[��C�	<��/ƣ�j�p��;1�=���x������ĥ��WEZ�� ����N��|����������+��g�Fњ�ɲ�بk�&�	X��em#���k	I���"�cr�����J"!���T�P���������,�5u�_��U;� �	Dָ�o�����ړ�q\
[�]�k����?rk�l\��}��篦���W�|5�����X�;g�_��X����4��Dp���6\��k���-A��Q�$N��8A������d��#����E�w�qK�/�2E���?�V����?�1y7�����tp��� ��k2k(]j:)�4��G�M�W<������<yz5��t)�y�;F��������Q�!�	(��-�6�	T��چ���(��JlC����q���qP��8aa��]�"n�Ngڜ�d&�/�T�\�g�)��a��B>�ʝ�R��j��|Rm��j�۳�/�z$���qgZf��j�w�I��L�ܞv��%�VN2�f!uxX8�\��d�xHHUS�b��3۵�eγg��L���3#�{oi��w,����y����1p5�K�O.2���f��6�T���$�o�U�����|o���b���Z�P�zų�T�慽j^:�eg�L����Β�B��J���R)��9<��T��h�R��NI�:�褫���q5sTH������)��3'��#��-��.2�BR`j�wT:*��HQI_X��b�\��r��n�حU�'�'��\��1W)�	��ɥR��^f[�j2�m�'Kb�u^��n7^|k��)n,M��\}�ܶv[G�q�|P?�;�N��P
��I���(V�y���c'r��k�vΪ��nA��Xi�t/���Jt��i�@�z�\H����z����C[��{�V!���m�z�d>�xo���Vo����&��{{����
��F�&Z�T<j��*4�B� �/�dg�{o�2����1�7�EB9JD����x:���ut�;LtSz��oT��n��u�ř��{�Dܫ������`�Sr"�Ջeu��T>SL�1~0�#��ϻ�j�V�|̄�gs��A���bAcB�	�}$y�`��m����nz�+�O����C4���n�
�4�7������q��`�-&��r��L`'s�J��
��6������dN�AC�JA��vw�;؈$�V-�-w��
�-*�L�kf�H�(�,�k��+��e��rJ�r�pк��T��š�N��e5�����A�TV�J�D��ᶔ3��u��Wݓ�55�>��������(Yh�B�[n4�]m����_�2��������e�g�����n�
��2�i�����,&����n>59�g[�L�x;��H���VHZ-i�RC��x��d���}S8?jxGDo�ߎ~���I��� �+�����Dcvĝ��օk�mK���;��Q�ô��ښ��g%�ܽ�ہO��~���`I�h����v����4����t�_����S���NO���j��L�PFL/�0�����O���ioC�^n�@�&�%x1�p@��{�	�=��� ҨnX;1���T���!�6�`�f?	N-���C�4!�=��%N��v�/ߌ9 ��mhX�`�|+hޔ"_� ��b!@_;�^5d�;�D]��\&L?�4L���mc��(Н�W�a{o���dۣ��P���߆����ȏ5w�x�c���?��![z��m�LG�L�Ȃ5ӿk���yå�p5�B�d"=�
�سz�D��L�� �zp�Go<���r)�"PE����^���S�f���жa�2��D.�6�Chg�0.�SގAE"�n2U�z`oOg,�e��3��bT�����(��
8�r�|�t��tR�ϰ��Ƌ=�2���d��_��Gڎz���6tD]ψ�4к�"i_�?�I�W��ӄ7�z�Z�//���a��������H���F/?��o���H�6n3ah�G�����	<_9�h]d�Ï���vv���2����<)Yp��o��\)N��Il�8\g�*D�� [JY1X#8sE�A{A���9��>�!��oOO;��F�(p%�j$_�G�z���\6�A�xpd�Vbb�"��j������xRسܐ8T�c�ɯ?�K*��)�J�fB��UZ�_ ���X�kKG��E�~_����GG�p��ɵ=���SSy1���	1��odW}gH;�&�n{�G;�8��bE�W��:�v�������)w�hبAi��c~����e�N�V!�C���#zLx��A��y$ͩN�8�ۦ��Ϸn��@�M�x�}��g0 �t��1���G3���,�AT�4�έ j}�S2C]gvJ������%�u,-w�4M�nz���f��n�Ž~�v�b��v�$N�y:O%'vW�G�N�d�.�4-�4�� v �!1�0,����b�!v�|�q��U��.�V׭�����s���I=���X�k6ѷ��vա���'0�ɕm\��������������<z�����g�?��.��w&E���~������?�����ֳ	�.�|�#�Ǒ�kG�����7�~��o���'��|�IGbE�1��(Q:��$!�-%��U���N�)�'(��)8AP9'���E�BC�ʯ����o]�ďc���?�ӹ�������~C���~����[+����C�{�6�_�~��������b����/����.�-�woB�C Z��b��C��L+ߋ�*Ǧ���U�8�X,ǜ���E��/�s�.�
�-��W!tUSd�N�X܍���";rXsQj�ٝ�Q�6�-B<o���"%�7e���yV��!bZ�'�L�A�5$F�JbI�xgho��Fm>n��@��d�4o�=�[fz�An�&r3�Է��p��Y{��yvP%5�j�*�7Œe��0����y�L��x��j�_$p��r�~�8���;P�=4�|�2-�16N��	n��j2�|�X+���-��L&s�2~a��T�B�����I��@7KX�)�Q��׾��L"�2���L#��I�cq�,9�+�gKf!gE���nJ6����wӄ�O%�B� �e�F$=+
��"��;����Q�Jv�%F�&�sT���lC滢���1�Zk�
=9�Ʉ�����4;�&�T]oW(Z����Ĥ�1f6n�R~n�'��X�x��cU���������_�Mw�^"w�^"wE^"w^"w�]"w�]"wE]"w]"w�\"w�\"wE\"� �W0��F9��7�O���õ�R��9��?�Kx)Ξ/q:�kbz)1\l��^�Ί�bMI͗�=wQ=x(��V=�=�S=1+m7� ��ϛX+};��x����,�t��R��42g��q�EL-ڬI���B�%�Q��&�JK!B�g����@�ɊL6K����	N���H�PE�z��x��y�O�9b:�	&Nb2��ٲ�'�L�e�|i���"�V�W��.U?Y&=#�y���8����RV�`+��6jݸ��"f&�S���ԳQf��t�P�T���ѕf%?i�pr���$�=��2���_��N��^}:
�i������no�֟_ [��y	����J�7�>C�K8��`�oo#]k/B���>�z�����P7�~�Aݚ.{����q�BGv_�}-��߁ˊ����[�(��B��M$�+��o>��|���<���=x��׊���e�������%Cclm�㣥:�t�[:_�^��OrL���	b���V�,oQ���Bnc5����$r�9(�Gt-��.�ܔ�u��x8�o�BA��R����]e!�+�!���ňf��Ev�'��)��3�ܸ�&ϋH�.��٩�� Z���6�
M��צ�Ġ���q�2�M�1b�ڲ>Hf��0�TGx�B��w�L�x���'�t{9-�������� +1@��Q1iA�E�M�r�_4�A�S餎��hԔS�[�\#Y�j���/�SdMQvsi�cyFc�����.�*�A�$�%���mAt1���A�b��銭�>ƌ"���;T{��7g�lM8ϐh[�2:Y�^�*{��o\�4	`(�|C��Ƞ�P�i6�ǲy�;핖[����EdO�g7�䒩z27��<���\ŒuN�#"�X���E��/r��~&8�8��U=��#��w��h�3�{����j�����
G�[�e&�<WLC�%�+�l�h�i��6��pXVsY��_ӊ��Z[&�����j6�Ҡ����EQ(0Ø�8��C����;T�ʈ��ʼc('D��Nf9gEK1��`.R�n�@
�dz>���q�ֻ8��tb��l�B�v������v����cDyzڮ�
j�YU3�Z_�(c>S��2��@�h�|z^*I6�t9���ҩN?��>�t�Åe��x�g0#�D��2���粉��Z��I@�,V�D����E�"g�JO��[V�����HFV�q�<�ُ:r�#1eAe����S&���R���v�S&%`�{
	�y�W(��0R�Tۧ��A����S�6��>���|�`:5"6k�B������u&^n�P�5�x��+�Q������t�!�eo4�m
�i�
%Z�6���1[�.-Y�K��*v334]���Ub��&H_&Ŵ�!y}����V��x��P��|�SJ��4%�^���l��:A���|l�0Y��ʬU�7��<hY"K���k�(G���l���<�����ɷK#+���C߶m�������A��/D�v���DV&��6�/ \[���Ds�������ip����!-�j��Л��H�Y!?��f�W֖j��[GȻϞ=�?|�,���6�6�#9��B��@�F�<;|�|��0���)���x���7�k�R���1�nZ6@�ZF��z`�#������Y8N6e�@~�N�������g�w��ae��j���C�C���=z]���Y9B^s�;���[|�x"s~3�/L�|���Ȗ����o?����6��'�~8�u�z�NG�~'אn��;�0ZjX�n�p����ۏ���d#<�'�@5�SّwR{W���}��rGd������>WƦ����W����]= ��=	��T���!D����y�tu��|f]/���u��kZ�[u��~���9�щ����.�vLM��������"�	:Y�O�R	� �\ �O�A����]�( �� ��f��D���67 D� FW��AE_�oL���v����<�cxj X�x�,pX0�Fo4Օ�P�u v��i����3_���� ���|�V�ت���$��sH�q��,�Qإ�`wA���9��
Zt�78�@} k�u��.����Ù6��~�5�>�\�6��Dj���Y@����_��)X��'�M<l+MN���l�ܡ����5��+s�:	�]BG~�WĀ�Mt`���X�N� ��&��G/���VB ؆��6lkcY?	�Fv�"/�|	Y-j%�ȗ[/$�̀\3�cus�7�7�zP���f�{�	�v�!a?
�Z[�o�æB���"������0�����6�n��CW��� :]l*DO��a�7��Lw�]�[޼���Kh���\��A��Q`[���S$%�I��4���|nu�Z]����E��͖]����А�b�	�l} �u�dMT"[W���6���r_����}���� @���Ke��D{Ꙭ��e��~�%AL�����m�idq����+Nx�l��u�b��c��� �<�б�~Z�� tFj�P9�ea=����0a��R������eQ
�9� \�U導5�"�âS6���sm0�j��v�N�P ~6�{(��[�BƂ�1-{���nͲӞdg������@.��~d9x��^�h�nKYuqձ'+�6a��6��E6ػ���Ŗ���/�a�{l|��۴�#ƽV5���-B$�M�6��[�d��N��|��]M��SwFN��Zf'�>Pv�ùt�[�H�P�fu]���ry�?x�P8�Q�#s�6����8}��x:'q,N�$E�r�ky]���N��$p���n(M�D �o1�n�+��0TMk4�rc�R~��qC��~T�P��Q�b��];�����p��u�����1q�m��������<��O+��$���dG�GV�@k'7��rv<���I�-	��sBc<EU����%��|�ʗ�o9ƮbGo���*��%��_m[��<�>��4t�7��� ���!�-*'T����Cӝv[��J���2ъ���	��iu�L�1U&h���;�����G Ċg>s���fi/���d�?��~l?y�
���x;ğ0�ξ�x�*�ܢ)��jad�*��*���,�4M��(�cjDn) ���g2Wɨ�˴��~�r ���c+�X����6�j`���Ͻyn���MG�.���̹(���팻6;���x��>x)��K_��:����=��SY��g�*jkڽ<�P���q%�\~�A�
�47��,�E^J繧�������;������J0Y�\�����r�XW[]c����*�Ʒ�dg
8�AGc���jL�hW3{�$���Z�Z�E�N�Fg縃��ަSo�ֲ=���(
�A�`�[ݜ!���G$�	����i~;��ȗx@�)!�:+�|i����D�r�<���0ǳ��z֪x��B^�IO�Cm~��(�j���	:�]��$PX4~f��H���]2��ti�o\>qjM��R"�K
��/��S��S��΂�v�]��Lr;��ԩ��H�m���e�<��˖%F❟#1,S�&@4T��""_I�9����7A^0U*#_(���[|M
�<vg^�|ڑuC�����E!�`ܱ˸�'��u��;��@���Yt7��f��u�e�Е�n�_��u��l�mp�i���%	 �<�ح��|W˛��zw,9 ��G{V)e�66��B�@�Eg��7�>��������M�M⿬���N��#�q��tG7]���O�z��酯������G��뿏�J����m������>���S7��m��>�����^ҫ �	۔�T�<��}�}����/�=_ٴ/���_�""�����}/����������z��o�~��J�Ԏ�_�o/i_����e{�Q�։�ܖ$�)�N�j��܎Gcx[�cX�iG�h�%cjST�$�����^���Ʒ��C�������&��Z��64��H����r\�:hZl���E��H�a��yu��^�O5����)�-c���ƌV"*�5�&�+-
��XE;����y٘����I9�8�t��IOO'�,���6L�ƨ�]����v~��U������K/_�;����!�N�X�ۜ������>ҫ �	l��� ����%�/����� �����������>�=� Ӿ�)�J���?��{���bo������W@�Û� t8%�:�����w�O���>��}�WK�C?���{�֜(�u���U#���[�qRA���[��xEE���&��֙��x��ו�d�Vt���{��D�CU��O�4���?	�?� �ꄣ:����O	�G<�����J���}(�k���[�!������E@��a?��P�3���'I@�_^���[�m��*ݠ��y�qXw�N��K����?�Z�?CCJ_�?���'�3����0�c�{�����o��(��'�*�z~�����'��H��J
�Z��Իi3���^3W=�P8�i��Dy0��d�|�V�k����*�e�e�lbW����e�?�,���>_�>���l�����ոCԣ#����L�Hi�di��қnW�E���v�S��͵�<HS_��v�5S6����qF��,T���;Ʋ֞�C�a���vC����S�N�|X�u-���?����f ����_�O�`���?��C����_��H��H���H8��@��?A��?�[�?�$�*���˓������[�!��ϟ���?�_����?�������ë��ε����ΙtN�� �YR׭u2`��������W�����/e}�GC���{��?t܌k�Ӏ<k�:χ�ڈw���7���>���GuY�˄b�鍂�i��\

��u���O�}����Y�4������Z�G�!Ou��� �X��%�R��BKſ��>�[����-m!�tBvJ�)�wN��%���F��beL��dR��lkx��D�;g�-��IK҈�^1�F��6�L����m̩�_���	�G<��*���[E����#(�k ���[�����w����/��W��6.�3�,�Yb��L@��B���|R,�\HRA�S!2�@x��?��Q�?����W���e�ӗ�DJ�V�d�<��Ӿ��Fԩ�,[�dm�K����3{{���S�.�#�Tݽ�ّ��66]���jrX�p�.6[J�=��y�&������� k�L�>�ó��:���V�p�����P������o�@���_}@��a��6 �����kX���	��C�W~e�w4-�9�j��\lcGo8g�L`�Uo��ۥ�-CƎ���R��=���#94�7/9�2�������慝��|�h|��8��S��#�qYRg~l8�xS�EƖ*�:�t����@��O��[������w|o�@a�����������?����@�$����?��W^�^y�1�-�Ӈ�,��q3�zg�P�<����-k��/��K�k;̱��Z�� �ӓ?q �g=����Tۣu�*U�v��g ��i��CW���!��2ݒ+|���ؠ�jJz��z��Ҷ�a[.C���Q��'�:kp���e/����7k���v�����b�z����p��{z��� �mI�!]끽�-�*>1q����/v�q<���i$)O��}7��k<oN����M��sC��7,kaH�����D+_jRƤ��ܟ4��jɚ:�q}�ZM~v얡ԘN���$ӹ���X��w����~OL�e$4#;�;�b��a�z|�c��ϒI4Ǘ���ws�E�A?�4�*����Ї	tQ�������<��0���@��I�A���+A%��~Ȣ*�������P�< ���!�����"`��&T���X�� �y���3������Y�"�Y>��`v;§Hr��E���,v~P���������r����U�e.3�,<�Ę$ G#Q>+fA/�݈.YӠS������C%�d�:��vI/�t��=����F1ĶJ�gɦ�O�8�.��f|����k�S����1\�z�,�^���qjӂ�߷��?A?8���J����x��U�U\�w��,E��_���������P���M�(���n�'�;���*B��/����AU������_x5�����o��汿��ˬ)�/�KRu����ò��oE�_�U�\`?3�}{����[+����[���3��N��a��~���~�,��:ێ1J{'Μ$S}�d����C�+u���xĭ��|����gv�0�q^V(�isZn�C֣�K;.���H=C��ح��<g�߮m'V�0�-m���$M����*��.��Q�����[���]�C���~*;Օ5K�s�b1Y�w�3�h�/f,4[��)�۱[���<k�Zl3:�n��e��R5�U�0�hc����xr�i�;�Lw("=�]P�W���քj���*������'	
�_kB���������7�� �a��a�����>N��9X H��ϭ�P���ׇ����!� � ���A�/�@�_ ��!�����?���A�U������/��u�������������$�����������m�n �����p�w]���!�f �����ă���� ��p���_;�3����J��C8Dը��4�����J ��� ���������a��" ��`3�F@�������� �W���Bj 
�����*�?@��?@���A�դ� �F@�������ڀ�C8D�@����@C�C%����������� �� ���$���� ����H���g���W����+
�?����������W��?$��@���� �o]�C�����P�n���S�}������Uxı�9���9/D��P�I*���g>R4���B@p�/�4�p��?�����X�����0�F�
�?�:}��۝k�)�S*��¿y��V�z��&M!Y,���n��l���Ӻ�Da9ԭ-y\ES���$�k3�]�-_�����D1F�V��2���w�!�I,/�[7M�N��H?��{�����G�H2�!+��^T�o8b@���������a]�Z���������Om@������2��7�����>���oRsn�N�jl�;4z�H�,�rؾ��-bp>\�L��_�?'Z죽6�&�o8�~��f���X����c�kqt&�-m�t�G)���b����n�3�A�"�fT�����v9X��	��[������w�+����#������(���W}��/����/����_��h�:����~�����>���S�_�����鈒����+_�x)���\���_�����M�)�'ym"V�u ���?*��U�͆rZ	;��;�,��Ac3%؍���¡���v/��0��z8��%��� ��Tn����]�þ㛹�N�^ۍ�/��-����ɷ��mI�!]?{)V[��_'.E{uY�O�b�ǃ�l�F��Dy�w#����c�O��ܤ]=�_EC�d�Ýw'(��B�dP	?�~�4�6��ٛ�ǣ�h�V�.&�6��(b+��T#f�j}h��L�3a�qG���m�p;뿿��O���E��o�����Y�`��,�s��*������z��t�'(��W�?�~��	�ߕࣿ�O�n0�,���?��4N������$N��i��*P�?�zB�z����1�������?�_x��3Yg�o��y�X�v�pG���l�S�]��_���RD�%�C&�o��E��qS���W���{��.�,?��~�X~�7��*��KϷ8|o]���X�Ûuys.o�%؟cKƎ�Hq��iդo��!I�m���n)����5rvmTl����F�j_e����1ɟ<��bR-NF�kQ��f��=�d׮��mj]��S���b�|1q��s�����7���]_/k!�S��XT����=��s}��4��31Sb+�d�s{SgG5$k�-?"������ٱ��2"ϡ��V>mt��\��숊���D.z��KDLw+8	f6��#N&�y �6�&��H�F��R�6}���S��o����*qOm*���x^8쾲���$�s7��ߊP���X��n�4�s*$���4
s�&�7��<�hJ���!�Q ~���6�?
(�����W����W��+l<;���`������Q0���c�=���3r�Iї��{��g���G���
�����������0�_@A�u�����|���CU\�W�?�~���W	^��z�����ځ?��<���b��p������;��a��2P�̓�w3ذ�y���~��x7�{��71$�����~/��6�Ϣ��ݱ��hu�#+�݆�����v@�O�L�f�k���H6��K�EȊ�&��<k��G�9?��M�'Z��l?콾ߋ�=���@-7�$6�Dt��<jp��o�;Q��eڲ��XԦ�RԱǾ��L��j0i��p7��;ф�W���D�q&hZ�f�!�_����[ʜh.�m���Q�;m{cm٥��f�����q������ �G>�����JP����ِ#��	���$y������E�<��y�ǯ�%�j�O0�O���(0�>U\���(���J�+��V��dm"2Z��9�,��h�7��0��J�U�:�r�I��/[n�{�l������-���G��U��U���?�_�����v�G$��_7�C�W}����c ��������w�?GB�_	^��ȷ������ִ��4wc�^O�{�<>.����/�pI{��}�c�G/�>*s���}mI�DqT�P�s�^Leu1���9���;�7�%���_�掮�ʷ��yث�� c~��U0~ ll��_��N:�g��$&���m0�c���s��\ޫ|x/-������SW/3W��ҕKa�|zMyX]�����������I+���8r��N�w�u�ѡ�J4صF�J���V�AVc�;�񩺪0��kX�,�mfe���mW�^ɕ�+b���t�j5��F	/Kh
�e�G�������~��Y�R7Q}�oM�w�Fu����Yۻ?^l뎤6M���V9��5�Ju�����Bh껺9)u,e6���x5�Y��{���l���)���@p�2`JJM�WR�Ue^�M��r���VI��@�~I;����2y���[�C�O&d���:8�y���������:��������?�"�g�B�'�B�'���������p�%��߷�����td��P.g��������?��g���oP��A�w��~D�Y��UD�����	�6�B�����P�3#������r�?�?z���㿙�J��エ� ��G��4u��?eJ������G��̍�_(��,ȉ�C]Dd��_W��!��C6@��� ��\���_�����$�������r��ū���y��AG.������C��L��P��?@����/k��B������r��0�����?ԅ@D.��������&@��� �������`�'P���@�?b���o�/��ܨ� �_�����T�����d@�?��C�������`�(���u�b?���G���m��A��ԕ��?dD.���h��H���Y�,34���L[�i�s�Xb-�/Y��p�me=��2Y&�"Gr���Gݺ?=y��"w��C�6���;=u��Ex]����JMpd�)6�U�M����H���D��
��籁n�����N�"Y1�i�������N�e�B�b=9�l7�EO8OW���n��Q�tA�K1s�C��F+�%Ys�!���5��f���q�r�Q��̼������$���ۃ����߻�(��3���C�Ot����5���<�����#��?�@���/|L�@ԭp��A���C����D�i�ʮ���cb"�X��Iٴ�q�r���-񻸺�9����W�G�����6��=r[�l��`�R�K�#���Ru���Z�$�u{8�t��.����o������J	�!E��Г��{+����0������?���ب#r��_Ȁ�/����/�����������\�,we�1�Y���O�_����n9qX"��{va�*��睟���N�����+bU�)T`����@q��`�z�M UAl��q�%I�ݟ��ݢ��Ǻ1��oR�K"}&v2.l����ة���$��ɦS'��m��yPԻ��R�ꇰ����Q�M��Xg�p��OY���0���C��39���U�kV����(v����^�l��%�@MR�/�.n�ZEp�7�|�M>�ͧ�6_Upe�N���=��*f���˴ζ���:l6���4��0-Ų���ұEI(���w�~�4d���1�݁㒶��z�vЅ^맷�^���b��*~t���{�,~�/���7�?H�?� ������A�� 3�~���	���G��4ye��<��H����������O�����L@���G���?�?r�gn�@�o&�I��
d�d��_[����?�����������1��_& ��`H�����_.��@Fn��DB.��:�����L�b�������P�Ҿ=�\�#��-��M��m^��l�?̤�}��Hا܏sb�m����܏�a%�����!�w��/��헼ߗ��my�ݢ�k]�DUk���8�P	:Vu���\�����j�7�jLkwCvfn}ar��1,3
�$>�!*���dS�W��9��ּߗ�_�Fޯnȧ�+
��
C[)H��Ǻ�o�9+�j�_�u�:	u�vޯ�N��3Qj�n6#�X�YMڒ�uH� ��f5LL���i��u+6E,D�Z0k�0�{�����T��>U~����\�0����߫E�Q��=��}�����GF����%�dJ.����(�����������B��30������E�Q7�]��}�����GD����0 �Ʌ�������_����_�Զc�^[������Hk9��d�S��W��>��$��2<�ڛ���܌�/i
��=��!�������2��ӋzI��&���zA��T�i��,�ط"S�_�*Gc���hA�f�P+rI{+��eY%#�s �s�_���I ��K��'�θ�.,�r t)U�W��|a)��a�-?��¢��^kO�����lT޴��P����^W;K�X$mW0�	�m%������o&�uc����	������n���������E�F��"��G��2Ûz��mN7�rI��EҠm�48ƠXڦi�T�XʴI�'m�5-��r����>�Q���L��������s��?��.㕌�t�'l����ҩ�׏&�^[�WUk�/�GB��S0�P���i'"�9��SV��,����~�q��K��aG�݃"���1K&�m��:�����X��������@����B� wN���Б���d ���E S7uS�%y�����=��`�[�˪�Q4���X�X1�x)��~�W[twJb��������#��t���y̚��Q�X�򈝐�o��1?��Ӯ�͊ۊa2O���ڏ��&YG���14�o%��U��3��g����a`��"���_���_���?`���y��X��"�d�����#}��3��޾ct�\�����B�����s�����- {Y�u@a�D;}-s�V׻�僂f'Q�\�t�\-�֨ܢR󩌭��������q�I8Xl�m�P�'Vo�� ҌU�Z۶�^J��������<Q�Z�����U�'SQ�kBr��;��IS�<_ ��0`Q��?��A��x���J�*āl�~1�&�*��H&�v�pO�ҳ��AzӬfmm�짆�T�}ض�h/b�i*y��=�f�Ŕ��r�ޒ��p\;�c��~�:�}��1kV�Y�nO��r}Dk�^�9��p����L��Ư����ľ�s�����>��O2������ǰ��Yp�����V����ܹ���ig�x�7��?�� �T�TU�w�A��_:�
v�/>������-\z�s�SAI�&r#�����.׾��?�_�e��q���G���Y�CI������냚�7�;y�V�����������??%q�i�c��������r�?�4O���g�?��0\�0�h�a���㾇�nŸ�~�o<]/������lto=b�����%�<^X��C+�s�����_���/ܜ��������׿�B�����$�����������y�*=*���������s�a�T�������މ�t���f���������a~��DO���C�v�pm�+�/�������z��޷/���"�p�y����T����o܍���*������M�=���k=<���V�?�e.|���n��;�-+�í��]D��s=����s�L<���|�C�z��?���?n^���7|���I�LE�sq=77a�&���xċ�����j����)�-��"?������=�}G�{����nUU婣�:�s�.:�e��Ͽ�û75��|����ܕ����G���.�                           ����g�� � 