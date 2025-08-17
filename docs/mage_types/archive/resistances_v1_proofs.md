#discussion ### Proofs
#### P1 x P1
Blue x Blue
$$\set{B} \times \set{B} $$
$$T = B \cap B = \set{B}$$
$$V=Length(T)=1$$
$$S=[\set{B,B}]$$
$$U=Length(S)-Length(T)=1-1=0$$
$$U=0\therefore U={1 \over 2}$$
$$Matchup = {1 \over 2}V*2U = {1 \over 2}(1)*2({1 \over 2})={1 \over 2}$$
$$Matchup'={U\over V} = {{1 \over 2} \over 1}={1 \over 2}$$
#### P1 x P2
Blue x Red
$$\set{B} \times \set{R} $$
$$T = B \cap R = \set{}$$
$$V=Length(T)=0\therefore V=2$$
$$S=[\set{B,R}]$$
$$U=Length(S)-Length(T)=1-0=1$$
$$Matchup = {1 \over 2}V*2U = {1 \over 2}(2)*2(1)=2$$
$$Matchup'={U\over V} = {1 \over {1 \over 2}}=2$$
#### S1 x S1
Cyan x Cyan
$$\set{B,G} \times \set{B,G} $$
$$T = C \cap C = \set{B,G}$$
$$V=Length(T)=2$$
$$S=[\set{B,B}, \set{B,G}, \set{G,B}, \set{G,G})]$$
$$U=Length(S)-Length(T)=4-2=2$$
$$Matchup = {1 \over 2}V*2U = {1 \over 2}(2)*2(2)=4$$
$$Matchup'={U\over V} = {2 \over 2}=1$$

#### S1 x S2
Cyan x Magenta
$$\set{B,G} \times \set{B,R} $$
$$T = C \cap M = \set{B}$$
$$V=Length(T)=1$$
$$S=[\set{B,B}, \set{B,R}, \set{G,B}, \set{G,R})]$$
$$U=Length(S)-Length(T)=4-1=3$$
$$Matchup = {1 \over 2}V*2U = {1 \over 2}(1)*2(3)=3$$
$$Matchup'={U\over V} = {3 \over 1}=3$$

#### P1 x S1 (Resistant)
Cyan x Blue
$$C \times B = \Set{B, G} \times \Set{B}$$
$$T = B \cap C=\set{B}$$
$$V=Length(T)=1$$
$$S = [\set{B,B},\set{G,B}]$$
$$U=Length(S)-Length(T) = 2 - 1 = 1$$
$$Matchup = {1 \over 2}V * 2U = {1 \over 2}(1)* 2(1)=1$$
$$Matchup' = {U\over V} = {1 \over 1} = 1$$
Blue x Cyan
$$B \times C = \Set{B} \times \Set{B, G}$$
$$T = B \cap C=\set{B}$$
$$V=Length(T)=1$$
$$S=[\set{B,B}, \set{B,G}]$$
$$U=Length(S) - Length(T) = 2 - 1 = 1$$
$$Matchup = {1 \over 2}V * 2U = {1 \over 2}(1)* 2(1)=1$$
$$Matchup' = {U\over V} = {1 \over 1} = 1$$
>[!note] ExD = DxE
>As shown above, it shouldn't matter if a Cyan mage is hit with a Blue attack or a Blue mage is hit with a Cyan attack. The effect on the mage will be the same regardless.


#### P1 x S1 (Supereffective)
Cyan x Red
$$C \times R = \Set{B, G} \times \Set{R}$$
$$T = C \cap R=\set{}$$
$$V=Length(T)=0\therefore V = 2$$
$$S=[\set{B,R}, \set{G,R}]$$
$$U=Length(S) - Length(T) = 2 - 0 = 2$$
$$Matchup = {1 \over 2}V * 2U = {1 \over 2}(2)* 2(2)=4$$
$$Matchup' = {U\over V} = {2 \over {1 \over 2}} = 4$$
>[!note]
> This will get clamped down to x2, if that's the direction I decide to take.