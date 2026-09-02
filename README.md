# Speaki-Language
![스피키 안보이는거예요?](./imgs/speaki.png)  
  
트리컬에 나온 스피키의 대사들을 이용해 만든 언어라곤 하지만  
사실 그냥 이 언어를 파이썬으로 번역(?)하는 것 뿐입니다.  
  
학교에서 했던거를 기반으로 만들어 매우 간단한 기능밖에 없습니다.  
  
macOS에서 진행했습니다.  
## 빌드
```
xcode-select --install
brew install flex bison
brew install cmake
brew install python
```
bison은 bison --version 했을 시 3.x이어야 합니다.  
  
모두 다운이 완료되었다면  
```
make
```
해주세요.   
spki 파일이 만들어졌다면 성공한 것 입니다.  
  
만약 코드에서 뭔가를 바꾸었다면,  
```
make clean
```
해주고 다시
```
make
```
해주세요.  
## 실행(?)
test_files에 있는 것 들을 예시를 들어,  
```
./spki < filename.spki | python3 
```
하면 아웃풋을 파이썬에다 파이프하여 실행해줍니다.  
어떤식으로 파이썬 파일이 만들어지는지 확인하고 싶다면,  
```
./spki < filename.spki > filename.py
```
를 하면 됩니다.
## 제약들 (파이썬과 다른 점들?)
- function definition은 c처럼 위쪽에다가 해야 놔두어야 합니다. (중간에 두면 안됩니다.)
- c처럼 ;같은게 필요합니다.
- if, while, foreach를 한 후에는 endif, endwhile, endforeach가 필요합니다.
## 에러들
- 아앗, 실패했어요... : lexical error
- 네르가 진거니까 네르를 탓하세요! : syntax error
- 스피키 역부족이었나봐요! : malloc failed
## 부가적인 것들
- other 디렉토리에 처음 만들기 시작할 때 사용한 버전이 있습니다. (spki_orig.l)
- other 디렉토리에 토큰이 어떤식으로 번역 되는지 적혀있는 텍스트 파일이 있습니다. (tokens.txt)
