module OpsManagerUiDrivers
  module AnimationHelper
    def disable_css_transitions!(page_context = browser)
      page_context.execute_script <<-JS
        // Turn off jQuery animations.
        jQuery.fx.off = true;

        // Turn off CSS transitions.
        var animationStyles = document.createElement('style');
        animationStyles.type = 'text/css';
        animationStyles.innerHTML = '* {' +
                                    '  -webkit-transition: none !important;' +
                                    '  -moz-transition: none !important;' +
                                    '  -ms-transition: none !important;' +
                                    '  -o-transition: none !important;' +
                                    '  transition: none !important;' +
                                    '  -webkit-animation: none !important;' +
                                    '  -moz-animation: none !important;' +
                                    '  -o-animation: none !important;' +
                                    '  -ms-animation: none !important;' +
                                    '  animation: none !important;' +
                                    '}'
        document.head.appendChild(animationStyles);
      JS
    end
  end
end
