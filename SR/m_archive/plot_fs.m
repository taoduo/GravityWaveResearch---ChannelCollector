scatter(omegaArray(:,1),omegaArray(:,2),7, log(omegaArray(:,3)),'filled')
c=colorbar('FontSize',20);
c.Label.String="log(\Omega_{gw})";
xl=xlabel("Transmission");
set(xl, 'FontSize',20);
yl=ylabel("SRC detuning phase (deg)");
set(yl, 'FontSize',20);
xlim([0,1])
ylim([-90,90])
yticks(-180:45:180)
set(gca,'FontName','Times','Fontsize',20,'XColor','k','YColor','k')


