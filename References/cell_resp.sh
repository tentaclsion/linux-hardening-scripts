#!/bin/bash
b="\e[94m"
r="\e[91m"
y="\e[93m"
g="\e[92m"
p="\e[95m"
nc="\e[0m"

function glycolysis {
        clear
        echo -e "The first step of cellular respiration or lactic acid fermentation is glycolysis, which takes place in the cytoplasm. The process of glycolysis takes a glucose molecule and splits it into two pyruvate molecules. This is done in two separate phases within glycolysis called the investment phase and the payoff phase. The investment phase actually uses ATP in order to split glucose molecules into two molecules of glyceraldehyde-3-phosphate. The two G3P molecules are then transformed into two pyruvate molecules, producing 2 NADH and 4 ATP, or net total of 2 ATP. The ATP produced is a result of substrate-level phosporylation where an organic substrate molecule transfers an inorganic phosphate group to ADP, producing ATP."
        printf "$r Press Y to proceed with model...$nc"
        read -p "" -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo
            echo -e "$r                                               Cytoplasm"
            echo -e "           Energy Investment Phase                                    Energy Payoff Phase"
            printf "        ATP Used                       ATP Used         \n"
            printf "         $b --             $y -*        $p &&     $nc ^^   $b ## ##      $p()   $y)(                           $y%% $nc\n"
            printf "   Glucose $b --           $y  *-       $p  &&    $nc  ^^  $b  ####      $p()     $y)(                 $p++    $y%% $nc\n"
            printf "  $g **      $b  --        $y   *-      $p &&     $nc ^^                 $p()            $nc[]       $p++      $y%% $nc\n"
            printf "  $g ***     $b --         $y    **     $p   &&   $nc  ^^                $p()            $nc []        $p++    $y%% $nc\n"
            printf "  $g **      $b  --        $y     *-    $p   &&   $nc  ^^                $p()     $y)(               $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&    $nc ^^                 $p()     $y)(                         $y%% $nc\n"
            sleep 1
            echo
            echo
            printf "         $b --             $y -*        $p &&     $nc ^^   $b ## ##    $p()   $y)(                           $y%% $nc\n"
            printf "           $b --           $y  *-       $p  &&    $nc  ^^  $b  ####    $p()     $y)(                 $p++    $y%% $nc\n"
            printf "             $b  --$g**    $y   *-      $p &&     $nc ^^               $p()            $nc[]       $p++      $y%% $nc\n"
            printf "             $b -- $g***   $y    **     $p   &&   $nc  ^^              $p()            $nc []        $p++    $y%% $nc\n"
            printf "             $b  --$g**    $y     *-    $p   &&   $nc  ^^              $p()     $y)(               $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&    $nc ^^               $p()     $y)(                         $y%% $nc\n"
            sleep 1
            echo
            echo
            printf "         $b --             $y -*        $p &&     $nc ^^   $b ## ##    $p()   $y)(                           $y%% $nc\n"
            printf "           $b --           $y  *-   $g**$p  &&    $nc  ^^  $b  ####    $p()     $y)(                 $p++    $y%% $nc\n"
            printf "             $b  --        $y   *- $g***$p &&     $nc ^^               $p()            $nc[]       $p++      $y%% $nc\n"
            printf "             $b --         $y    ** $g**$p   &&   $nc  ^^              $p()            $nc []        $p++    $y%% $nc\n"
            printf "             $b  --        $y     *-    $p   &&   $nc  ^^              $p()     $y)(               $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&    $nc ^^               $p()     $y)(                         $y%% $nc\n"
            sleep 1
            echo
            echo
            printf "         $b --             $y -*        $p &&         $nc ^^   $b ## ##       $p()   $y)(                           $y%% $nc\n"
            printf "           $b --           $y  *-       $p  &&  $g**  $nc  ^^  $b  ####       $p()     $y)(                 $p++    $y%% $nc\n"
            printf "             $b  --        $y   *-      $p &&   $g*** $nc ^^                  $p()            $nc[]       $p++      $y%% $nc\n"
            printf "             $b --         $y    **     $p   && $g**  $nc  ^^                 $p()            $nc []        $p++    $y%% $nc\n"
            printf "             $b  --        $y     *-    $p   &&       $nc  ^^                 $p()     $y)(               $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&        $nc ^^                  $p()     $y)(                         $y%% $nc\n"
            sleep 1
            echo
            echo
            echo   "                                                        G3P Molecules as Inputs"
            printf "         $b --             $y -*        $p &&         $nc ^^       $b ## ##       $p()   $y)(                           $y%% $nc\n"
            printf "           $b --           $y  *-       $p  &&        $nc  ^^      $b  ####       $p()     $y)(                 $p++    $y%% $nc\n"
            printf "             $b  --        $y   *-      $p &&         $nc ^^          $g**        $p()            $nc[]       $p++      $y%% $nc\n"
            printf "             $b --         $y    **     $p   &&       $nc  ^^           $g*       $p()            $nc []        $p++    $y%% $nc\n"
            printf "             $b  --        $y     *-    $p   &&       $nc  ^^ $g**                $p()     $y)(               $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&        $nc ^^   $g*                $p()     $y)(                         $y%% $nc\n"
            sleep 1
            echo
            echo
            echo   "                                                               Makes 2 NADH                                             "
            echo   "                                                                        |"
            echo   "                                                                        v"
            printf "         $b --             $y -*        $p &&         $nc ^^       $b ## ##       $p() $g**$y)(                           $y%% $nc\n"
            printf "           $b --           $y  *-       $p  &&        $nc  ^^      $b  ####       $p() $g*   $y)(                 $p++    $y%% $nc\n"
            printf "             $b  --        $y   *-      $p &&         $nc ^^                     $p()          $nc[]       $p++           $y%% $nc\n"
            printf "             $b --         $y    **     $p   &&       $nc  ^^                    $p()          $nc []        $p++         $y%% $nc\n"
            printf "             $b  --        $y     *-    $p   &&       $nc  ^^                    $p()  $g**  $y)(               $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&        $nc ^^                     $p()  $g*   $y)(                         $y%% $nc\n"
            sleep 1
            echo
            echo
            printf "         $b --             $y -*        $p &&         $nc ^^       $b ## ##       $p()     $y)(                               $y%% $nc\n"
            printf "           $b --           $y  *-       $p  &&        $nc  ^^      $b  ####       $p()       $y)(                     $p++    $y%% $nc\n"
            printf "             $b  --        $y   *-      $p &&         $nc ^^                     $p()             $g**$nc[]        $p++           $y%% $nc\n"
            printf "             $b --         $y    **     $p   &&       $nc  ^^                    $p()             $g**$nc []         $p++         $y%% $nc\n"
            printf "             $b  --        $y     *-    $p   &&       $nc  ^^                    $p()        $y)(                   $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&        $nc ^^                     $p()        $y)(                             $y%% $nc\n"
            sleep 1
            echo
            echo
            printf "         $b --             $y -*        $p &&         $nc ^^       $b ## ##       $p()     $y)(                               $y%% $nc\n"
            printf "           $b --           $y  *-       $p  &&        $nc  ^^      $b  ####       $p()       $y)(          $g**       $p++    $y%% $nc\n"
            printf "             $b  --        $y   *-      $p &&         $nc ^^                     $p()             $nc[]        $p++           $y%% $nc\n"
            printf "             $b --         $y    **     $p   &&       $nc  ^^                    $p()             $nc []   $g**  $p++         $y%% $nc\n"
            printf "             $b  --        $y     *-    $p   &&       $nc  ^^                    $p()        $y)(                   $p++      $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&        $nc ^^                     $p()        $y)(                             $y%% $nc\n"
            sleep 1
            echo
            echo
            printf "         $b --             $y -*        $p &&         $nc ^^       $b ## ##       $p()     $y)(                                   $y%% $nc\n"
            printf "           $b --           $y  *-       $p  &&        $nc  ^^      $b  ####       $p()       $y)(                     $p++ $g**   $y%% $nc\n"
            printf "             $b  --        $y   *-      $p &&         $nc ^^                     $p()             $nc[]        $p++               $y%% $nc\n"
            printf "             $b --         $y    **     $p   &&       $nc  ^^                    $p()             $nc []         $p++      $g**   $y%% $nc\n"
            printf "             $b  --        $y     *-    $p   &&       $nc  ^^                    $p()        $y)(                   $p++          $y%% $nc\n"
            printf "           $b   --         $y  *-       $p  &&        $nc ^^                     $p()        $y)(                                 $y%% $nc\n"
            sleep 1
            echo
            echo
            echo   "                                                                                                                 Two Molecules"
            echo   "                                                                                                                  of Pyruvate"
            echo   "                                                                                                                       v"
            printf "         $b --             $y -*        $p &&         $nc ^^       $b ## ##       $p()     $y)(                                   $y%%        $nc\n"
            printf "           $b --           $y  *-       $p  &&        $nc  ^^      $b  ####       $p()       $y)(                     $p++        $y%%  $g**  $nc\n"
            printf "             $b  --        $y   *-      $p &&         $nc ^^                     $p()             $nc[]        $p++               $y%%        $nc\n"
            printf "             $b --         $y    **     $p   &&       $nc  ^^                    $p()             $nc []         $p++             $y%%        $nc\n"
            printf "             $b  --        $y     *-    $p   &&       $nc  ^^                    $p()        $y)(                   $p++          $y%%  $g**  $nc\n"
            printf "           $b   --         $y  *-       $p  &&        $nc ^^                     $p()        $y)(                                 $y%%        $nc\n"
        fi
}
function krebs {
    clear
    echo -e "The second step of cellular respiration is the krebs cycle which occurs within the mitochondrion inner matrix. It produces a net total of 2 ATP while also producing 4 carbon dioxide molecules, along with necessary electron carriers. The primary function of the krebs cycle is to produce the electron carriers NADH and FADH2 from their normal states NAD+ and FAD, using the two pyruvate molecules as inputs. The electron carriers are able to donate and accept electrons making them imperative to functions in the cell, such as the following Electron Transport Chain. Acetyle coenzyme A transports the carbon atoms of the acetyl group to the krebs cycle to be oxidized and reduce the NAD+ and FAD molecules by moving through the outer mitochondrial membrane and the inner mitochondrial membrane. ATP is also produced in the krebs cycle through substrate-level phosporylation. Carbon dioxide is neutral byproduct formed that diffuses easily out of the cell."
    printf "$r Press Y to proceed with model...$nc"
    read -p "" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
        printf "$g Legend-\n$p  Enzymes - Pink$nc\n"
        printf "$y Pyruvate---->Acetyl-CoA$nc\n"
        printf "                 $y, - $p~ ~ ~ $y- ,$nc\n"
        printf "             $y, '   $g Makes      $y' ,$nc\n"
        printf "  $g Makes   $p~~~     $g FADH2        $p~~~$nc\n"
        printf "  $g NADH    $p~~~                   $p~~~$nc\n"
        printf "          $y,                         $y,$nc\n"
        printf "         $y,         $g|Krebs            $y,$nc\n"
        printf " $g Makes $p~~~         $g|Cycle           $p~~~$g Makes NADH$nc\n"
        printf " $g NADH  $p~~~                          $p~~~        $p~~~$nc\n"
        printf "         $y,                           $y,<---------$p~~~$y--------Pyruvate$nc\n"
        printf "          $y,                         $y,    $g Makes NADH$nc\n"
        printf "           $y,                       $y,$nc\n"
        printf "           $p~~~ $g<-- Makes NADH   $p~~~ $nc\n"
        printf "           $p~~~                  $p~~~ $nc\n"
        printf "               $y' - , $p~ ~ ~ $y,  '$nc\n"
    fi
}
function etc {
    clear
    echo -e "The third step of cellular respiration is the Electron Transport chain which occurs throughout the inner matrix and the inter membrane with the use of proteins and molecules called complexes embedded in the inner membrane of the mitochondrion. The electron carriers NADH and FADH2 are then used in this chain to donate electrons to each individual complex, which results in NADH and FADH2 giving away H+ ions which are then pumped into the inter membrane, increasing inter membrane H+ concentration and creating a proton gradient (higher concentration of protons on one side of a semi-permeable membrane). This proton gradient results in chemiosmosis which is the main driving force behind ATP synthesis, as it is the movement of ions across a membrane through their electrochemical gradient, such as the proton gradient. These hydrogen ions move accross the membrane through an ATP synthase enzyme, binding with Oxygen as the ultimate receiver of electrons. This forms water and large amounts of energy through a process called oxidative phosporylation by binding a Pi and ADP, driven by the formation of water from the hydrogen ions and the oxygen. The proton pump is powered by energy gained from electrons passing down the Electron Chain."
    printf "$r Press Y to proceed with model...$nc"
    read -p "" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo
        echo -e "$g                 Complex 1                                         Complex 2                                  Complex 3                                           Complex 4$nc"
        echo -e "$b                 (((((((((((((((((((())))))))))))))))))))             (())                           (((((((((((())))))    ()))))                                                         $nc"
        echo -e "$b             ((((((((((((((((()))))))))))))))))                      ((()))                        (((((((((((((())))))))))))))                                                           $nc"
        echo -e "$b           (((((((((((((((())))))))))))))))                         (((())))                       ((()))    (((((((())))))))                                (((((((((())))))))))         $nc"
        echo -e "$b         ((((((()))))))                                            ((((()))))                               ((((((()))))))                                  ((((((((((()))))))))))        $nc"
        echo -e "$b     (((())))    |                                               (((((((())))))))                          ((((((((()))))))))                                 ((((((((()))))))))          $nc"
        echo -e "$b (((())))      NADH                                               ((((((()))))))                         (((((((((())))))))))                                 ((((((((()))))))))     ---> Leaves Complex 4 $nc"
        echo -e "$b                                                           FADH2 ---(((((())))))                        (((((((((((())))))))))))                             (((((((((())))))))))    ---> Through O2    $nc"
        echo -e "$b                                                                     ((((()))))                        (((((((((((((())))))))))))))                          (((((((((())))))))))         $nc"
        echo -e "$b                                                                       ((()))                           ((((((((((((()))))))))))))                          ((((((((((()))))))))))        $nc"
        echo -e "$b                                                                                                           (((((((((())))))))))                               ((((((((())))))))))         $nc"
        echo -e "$b                                                                                                               (((((())))))                                                               $nc"
        echo -e "$g     Uses NADH for electrons, NADH loses a H+              Uses FADH2 and loses two H+               Receives Electrons from Complex I & II           Receives Electrons from Complex III $nc"
        sleep 0.75
        echo
        echo
        echo -e "$g                 Complex 1                                $y /\    $g   Complex 2         $y  /\        $g              Complex 3                                           Complex 4$nc"
        echo -e "$b                 (((((((((((((((((((()))))))))))))))))))) $y  |   $b      (())     $y         |    $b        (((((((((((())))))    ()))))                                                         $nc"
        echo -e "$b             ((((((((((((((((()))))))))))))))))             $p*  $b      ((()))      $y       |    $b      (((((((((((((())))))))))))))                                                           $nc"
        echo -e "$b           (((((((((((((((())))))))))))))))             $p *     $b     (((())))         $p   *     $b     ((()))    (((((((())))))))                                (((((((((())))))))))         $nc"
        echo -e "$b         ((((((()))))))                           $g H+ Ions $p *  $b    ((((()))))                               ((((((()))))))                                  ((((((((((()))))))))))        $nc"
        echo -e "$b     (((())))                                  $g Pumped Into  $b    (((((((())))))))      $p   *    $b            ((((((((()))))))))                                 ((((((((()))))))))          $nc"
        echo -e "$b (((())))                                   $g Inter Membrane  $b     ((((((()))))))                         (((((((((())))))))))                                 ((((((((()))))))))     ---> Leaves Complex 4 $nc"
        echo -e "$b                                                                    (((((())))))     $p *     $b            (((((((((((())))))))))))                             (((((((((())))))))))    ---> Through O2    $nc"
        echo -e "$b                                                                     ((((()))))                        (((((((((((((())))))))))))))                          (((((((((())))))))))         $nc"
        echo -e "$b                                           $g    NAD+ & FAD         $b     ((()))                           ((((((((((((()))))))))))))                          ((((((((((()))))))))))        $nc"
        echo -e "$b                                          $g Reenters Krebs Cycle   $b                                         (((((((((())))))))))                               ((((((((())))))))))         $nc"
        echo -e "$b                                           $g        V              $b                                             (((((())))))                                                               $nc"
        echo -e "$g     Uses NADH for electrons, NADH loses a H+              Uses FADH2 and loses two H+               Receives Electrons from Complex I & II           Receives Electrons from Complex III $nc"
        sleep 0.75
        echo
        echo
        echo -e "$g                 Complex 1                                         Complex 2                                  Complex 3                                     $y  /\ $g Complex 4$nc"
        echo -e "$b                 (((((((((((((((((((())))))))))))))))))))             (())                           (((((((((((())))))    ()))))                            $y  |                          $nc"
        echo -e "$b             ((((((((((((((((()))))))))))))))))                      ((()))                        (((((((((((((())))))))))))))                             $y   | $p *     * $b                $nc"
        echo -e "$b           (((((((((((((((())))))))))))))))                         (((())))                       ((()))    (((((((())))))))                                (((((((((())))))))))         $nc"
        echo -e "$b         ((((((()))))))                                            ((((()))))                               ((((((()))))))                                  ((((((((((()))))))))))        $nc"
        echo -e "$b     (((())))                                                    (((((((())))))))                          ((((((((()))))))))                                 ((((((((()))))))))          $nc"
        echo -e "$b (((())))                                                         ((((((()))))))                         (((((((((())))))))))                                 ((((((((()))))))))     ---> Leaves Complex 4 $nc"
        echo -e "$b                                                                    (((((())))))                        (((((((((((())))))))))))                             (((((((((())))))))))    ---> Through O2    $nc"
        echo -e "$b                                                                     ((((()))))                        (((((((((((((())))))))))))))                          (((((((((())))))))))         $nc"
        echo -e "$b                                                                       ((()))                           ((((((((((((()))))))))))))                          ((((((((((()))))))))))        $nc"
        echo -e "$b                                                                                                           (((((((((())))))))))                               ((((((((())))))))))         $nc"
        echo -e "$b                                                                                                               (((((())))))                                                               $nc"
        echo -e "$g     Uses NADH for electrons, NADH loses a H+              Uses FADH2 and loses two H+               Receives Electrons from Complex I & II           Receives Electrons from Complex III $nc"
    fi
}
function atp {
    clear
    echo -e "The proton gradient formed by the Electron Chain results in chemiosmosis which transports the H+ ions across the ATP synthase enzyme. The H+ movement inside the ATP synthase enzyme causes it to rotate which allows inorganic phosphate to bind to ADP through oxidative phosporylation, a process where ATP is formed from the energy released of oxidizing NADH and FADH2. The H+ ions are bonded with O2 and result in water molecules."
    printf "$r Press Y to proceed with model...$nc"
    read -p "" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo -e "                                           $g Intermembrane Space                                                                  $nc"
        echo -e "                 $r         H+                                                                                                     $nc"
        echo -e "                 $r                 H+                                                                                             $nc"
        echo -e "               $r H+                         H+                                                                                    $nc"
        echo -e "                 $r               H+                   H+                                                                          $nc"
        echo -e "                                                 $p(((((())))))                                                                    $nc"
        echo -e " $y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$p(((((())))))$y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        $nc"
        echo -e " $y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$p(((((())))))$y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        $nc"
        echo -e "                                                   $p(((())))                                                                      $nc"
        echo -e "                                               $p(((((((())))))))                                                                  $nc"
        echo -e "                          $g  ATP     ----->   $p(((((((((())))))))))                                                                $nc"
        echo -e "                        $g Synthase   ----->    $p((((((((()))))))))                                                                 $nc"
        echo -e "                                                $p((((((()))))))                                                                   $nc"
        echo -e "                                                   $p(((())))                      $g Inner Matrix                                   $nc"
        echo -e "                                                        $p()                                                                       $nc"
        sleep 0.75
        echo
        echo -e "                    $g                           Intermembrane Space                                                               $nc"
        echo -e "                                                                                                                                 $nc"
        echo -e "                                                                                                                                 $nc"
        echo -e "                                                                                                                                 $nc"
        echo -e "                                                                                                                                 $nc"
        echo -e "                                                 $p(((((())))))                                                                    $nc"
        echo -e " $y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$p(((((())))))$y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        $nc"
        echo -e " $y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$p(((((())))))$y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        $nc"
        echo -e "                                                   $p(((())))                                                                      $nc"
        echo -e "                                               $p(((((((())))))))                                                                  $nc"
        echo -e "                          $g  ATP     ----->   $p(((((((((())))))))))     $g ATP                                                          $nc"
        echo -e "                        $g Synthase   ----->    $p((((((((()))))))))                  $b   H2O                                            $nc"
        echo -e "                                                $p((((((()))))))          $b  H2O                                                       $nc"
        echo -e "                                                   $p(((())))       $g  ATP             $g Inner Matrix                                   $nc"
        echo -e "                                                        $p()                                                                       $nc"
    fi
}
function cellularRespiration {
    clear
    echo -e "$r          _______  _______  ___      ___      __   __  ___      _______  ______                                           $nc";
    echo -e "$r         |       ||       ||   |    |   |    |  | |  ||   |    |   _   ||    _ |                                          $nc";
    echo -e "$r         |       ||    ___||   |    |   |    |  | |  ||   |    |  |_|  ||   | ||                                          $nc";
    echo -e "$r         |       ||   |___ |   |    |   |    |  |_|  ||   |    |       ||   |_||_                                         $nc";
    echo -e "$r         |      _||    ___||   |___ |   |___ |       ||   |___ |       ||    __  |                                        $nc";
    echo -e "$r         |     |_ |   |___ |       ||       ||       ||       ||   _   ||   |  | |                                        $nc";
    echo -e "$r         |_______||_______||_______||_______||_______||_______||__| |__||___|  |_|                                        $nc";
    sleep 0.5
    echo -e "$g                          ______    _______  _______  _______  ___   ______    _______  _______  ___   _______  __    _   $nc";
    echo -e "$g                         |    _ |  |       ||       ||       ||   | |    _ |  |   _   ||       ||   | |       ||  |  | |  $nc";
    echo -e "$g                         |   | ||  |    ___||  _____||    _  ||   | |   | ||  |  |_|  ||_     _||   | |   _   ||   |_| |  $nc";
    echo -e "$g                         |   |_||_ |   |___ | |_____ |   |_| ||   | |   |_||_ |       |  |   |  |   | |  | |  ||       |  $nc";
    echo -e "$g                         |    __  ||    ___||_____  ||    ___||   | |    __  ||       |  |   |  |   | |  |_|  ||  _    |  $nc";
    echo -e "$g                         |   |  | ||   |___  _____| ||   |    |   | |   |  | ||   _   |  |   |  |   | |       || | |   |  $nc";
    echo -e "$g                         |___|  |_||_______||_______||___|    |___| |___|  |_||__| |__|  |___|  |___| |_______||_|  |__|  $nc";
    sleep 0.5
    echo -e "$b          __   __  _______  ______   _______  ___                                                                         $nc";
    echo -e "$b         |  |_|  ||       ||      | |       ||   |                                                                        $nc";
    echo -e "$b         |       ||   _   ||  _    ||    ___||   |                                                                        $nc";
    echo -e "$b         |       ||  | |  || | |   ||   |___ |   |                                                                        $nc";
    echo -e "$b         |       ||  |_|  || |_|   ||    ___||   |___                                                                     $nc";
    echo -e "$b         | ||_|| ||       ||       ||   |___ |       |                                                                    $nc";
    echo -e "$b         |_|   |_||_______||______| |_______||_______|                                                                    $nc";
    sleep 0.5
    printf "$g Welcome to the Cellular Respiration Model!\n\nWhich step would you like to view:\n$nc"
    printf "$y[1]Glycolysis\n[2]The Krebs Cycle\n[3]Electron Transport Chain\n[4]ATP Synthase\n[5]Exit$nc\n"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[1]$ ]]
    then
        glycolysis
        read
        clear
        cellularRespiration
    fi
    if [[ $REPLY =~ ^[2]$ ]]
    then
        krebs
        read
        clear
        cellularRespiration
    fi
    if [[ $REPLY =~ ^[3]$ ]]
    then
        etc
        read
        clear
        cellularRespiration
    fi
    if [[ $REPLY =~ ^[4]$ ]]
    then
        atp
        read
        clear
        cellularRespiration
    fi
    if [[ $REPLY =~ ^[5]$ ]]
    then
        clear
        bash -c "./cellRespBruh.sh /; bash"
    fi
}
function ferm {
    clear
    echo -e "$p _______  _______  ______    __   __  _______  __    _  _______  _______  _______  ___   _______  __    _  $nc";
    echo -e "$p|       ||       ||    _ |  |  |_|  ||       ||  |  | ||       ||   _   ||       ||   | |       ||  |  | | $nc";
    echo -e "$p|    ___||    ___||   | ||  |       ||    ___||   |_| ||_     _||  |_|  ||_     _||   | |   _   ||   |_| | $nc";
    echo -e "$p|   |___ |   |___ |   |_||_ |       ||   |___ |       |  |   |  |       |  |   |  |   | |  | |  ||       | $nc";
    echo -e "$p|    ___||    ___||    __  ||       ||    ___||  _    |  |   |  |       |  |   |  |   | |  |_|  ||  _    | $nc";
    echo -e "$p|   |    |   |___ |   |  | || ||_|| ||   |___ | | |   |  |   |  |   _   |  |   |  |   | |       || | |   | $nc";
    echo -e "$p|___|    |_______||___|  |_||_|   |_||_______||_|  |__|  |___|  |__| |__|  |___|  |___| |_______||_|  |__| $nc";
    sleep 0.5
    echo -e "$y           __   __  _______  ______   _______  ___                                                         $nc";
    echo -e "$y          |  |_|  ||       ||      | |       ||   |                                                        $nc";
    echo -e "$y          |       ||   _   ||  _    ||    ___||   |                                                        $nc";
    echo -e "$y          |       ||  | |  || | |   ||   |___ |   |                                                        $nc";
    echo -e "$y          |       ||  |_|  || |_|   ||    ___||   |___                                                     $nc";
    echo -e "$y          | ||_|| ||       ||       ||   |___ |       |                                                    $nc";
    echo -e "$y          |_|   |_||_______||______| |_______||_______|                                                    $nc";
    sleep 0.5
    printf "$g Welcome to the Fermentation Model!\n$nc"
    echo
    echo
    echo -e "The process of fermentation differs greatly from the aerobic processes in cellular respiration, in that it is an anaerobic process. Lactic acid, or ethyl alcohol, fermentation does not require oxygen to produce ATP, albeit in low amounts, and replaces oxygen as the ultimate electron receiver with either pyruvate or acetaldehyde for lactic acid fermentation and alcohol fermentation respectively. Lactic acid fermentation still goes through glycolysis to produce two pyruvate molecules from glucose, occurring in the cytoplasm. In lactic acid fermentation, pyruvate is reduced by NADH to form lactate and no CO2 as no oxygen is present. Oxidizing NADH removes the protons, or H+ ions, to form NAD+ and uses an alternative to oxygen as an electron acceptor. ATP is produced through substrate-level phosphorylation as opposed to oxidative phosporylation, using the inorganic phosphate group from a substrate to bond with ADP on the enzyme. The end product is lactate which is the ionized version of lactic acid."
    printf "$r Press Y to proceed with model...$nc"
    read -p "" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo
        echo -e "            $g 2 ADP + 2 Pi                                     2 ATP                     $nc"
        echo -e "                $y     \                                        /           $p O-           $nc"
        echo -e "         $y             ----------------------------------------            $b |            $nc"
        echo -e "       $g Glucose $y--------------------$g Glycolysis$y--------------------------->$p C$b = O        $nc"
        echo -e "         $y                $y         , -$r > > >$y - ,                          $b  |            $nc"
        echo -e "                         $y     , '               ' ,                       $p C$b =$p O        $nc"
        echo -e "                       $y     ,                       ,                     $b |            $nc"
        echo -e "                     $y      ,                         ,                    $p CH3          $nc"
        echo -e "                   $y       ,                           ,                                 $nc"
        echo -e "                      $p  2NAD+                        2NADH            $p 2 Pyruvate       $nc"
        echo -e "                  $y        ,                   $p + 2H+ $y ,               $y     |            $nc"
        echo -e "       $p O-     $y            ,                         ,                $y     |            $nc"
        echo -e "       $b |        $y           ,                       ,                 $y     |            $nc"
        echo -e "       $p C = O      $y           ,                  , '                  $y     |            $nc"
        echo -e "       $b |            $y            ' - ,$r < < <$y ,  '                     $y     |            $nc"
        echo -e "       $p C $b-$p OH   $y<---------------------------------------------------------             $nc"
        echo -e "       $b |                                                                               $nc"
        echo -e "   $p H $b-$p C $b-$p OH                                                                          $nc"
        echo -e "       $b |                                                                               $nc"
        echo -e "       $p CH3                                                                             $nc"
        echo -e "   $g 2 Lactate                                                                           $nc"
    fi
}
echo -e "$g Cellular Respiration Model$b or$r Fermentation$y [C|F]:$nc"
read -p "" -n 1 -r
if [[ $REPLY =~ ^[Cc]$ ]]
then
    cellularRespiration
elif [[ $REPLY =~ ^[Ff]$ ]]
then
    ferm
fi
#sleep 0.5
#cat cell.txt
#sleep 0.75
#cat test.txt
#sleep 0.75

