FROM medicineyeh/arch-distcc-all-gcc:latest

MAINTAINER Medicine Yeh <medicinehy@gmail.com>

RUN useradd -m distcc_user
RUN echo 'Server = http://mirror.pritunl.com/archlinux/latest/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman -Syy
RUN pacman --noconfirm -Syy gcc distcc

USER distcc_user

WORKDIR /home/distcc_user

COPY run-server.sh ./

ENTRYPOINT ["./run-server.sh"]

