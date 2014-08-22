# == Class: role::drmf ==
class role::drmf {
    include role::mathsearch

    mediawiki::settings { 'drmf math':
        priority => 30,
        values => {
        'wgMathDisableTexFilter' => true,
        'wgUseMathJax'           => true, # enabeling MathJax as rendering option
        'wgDefaultUserOptions[\'mathJax\']' => true, #setting MathJax as default rendering option (optional)
        'wgLaTeXMLServer'       => 'http://gw125.iu.xsede.org:8888',
        'wgMathDefaultLaTeXMLSetting[\'preload\'][]' => 'DLMFmath.sty',
        'wgCapitalLinks' => false,
        },
    }

    mediawiki::settings { 'drmf security':
      values => {
        'wgGroupPermissions[\'*\'][\'edit\']' => false,
        'wgGroupPermissions[\'*\'][\'createaccount\']' => false,
      },
    }
    mediawiki::settings { 'drmf remove texvc':
        values => ['$wgMathDefaultLaTeXMLSetting[\'preload\'] = array_diff( $wgMathDefaultLaTeXMLSetting[\'preload\'], [\'texvc\'] )'],
        priority => 20
    }

    mediawiki::settings { 'drmf Namspaces':
        values => ['
        // See https://www.mediawiki.org/wiki/Extension_default_namespaces
        define("NS_SOURCE", 130);
        define("NS_SOURCE_TALK", 131);
        define("NS_FORMULA", 132);
        define("NS_FORMULA_TALK", 133);
        define("NS_CD", 134);
        define("NS_CD_TALK", 135);

        $wgExtraNamespaces =
            array(NS_SOURCE => "Source",
                  NS_SOURCE_TALK => "Source_talk",
                  NS_FORMULA => "FormulaH", //Rename once all pages with Formula prefix are moved
                  NS_FORMULA_TALK => "Formula_talk",
                  NS_CD => "CD",
                  NS_CD_TALK => "CD_talk",
            );
/**
 * Callback function that is called after a formula was rendered
 * @param MathRenderer $Renderer
 * @param string|null $Result reference to the rendering result
 * @param int $pid
 * @param int $eid
 * @return bool
 */
function wfOnMathFormulaRendered( MathRenderer $Renderer, &$Result = null, $pid = 0, $eid = 0 ) {
    $id = $Renderer->getID();
    if ( $id ) {
        $url = Title::newFromText( \'Formula:\' . $id )->getLocalURL();
        $Result = preg_replace ("#</semantics>#", "<annotation encoding=\"OpenMath\" >" . $Renderer->getUserInputTex() . "</annotation>\n</semantics>", $Result );
        $Result = \'<a href="\' . $url . \'" id="\' . $id . \'" style="color:inherit;">\' . $Result . \'</a>\';
    }
    return true;
}


$wgHooks[\'MathFormulaRendered\'] = array (\'wfOnMathFormulaRendered\');
        $smwgNamespacesWithSemanticLinks[NS_FORMULA] = true;
        $smwgNamespacesWithSemanticLinks[NS_CD] = true;'],
        priority => 5
    }
    mediawiki::extension { 'Lockdown':
        settings => {
        'wgNamespacePermissionLockdown[NS_SOURCE][\'read\']'=> ['user'],
        'wgNamespacePermissionLockdown[NS_CD][\'read\']'    => ['user'],
        }
    }
    mediawiki::extension { 'FlaggedRevs':
        settings => {
        wgFlaggedRevsStatsAge => false,
        'wgGroupPermissions[\'sysop\'][\'review\']' => true, #allow administrators to review revisions
        }
    }
    mediawiki::extension{ 'DataTransfer':

    }

    file { '/srv/vagrant/settings.d/DrmfUserWhitelist.txt':
      content => template( '/vagrant/puppet/modules/drmf/templates/DrmfUserWhitelist.txt.erb' ),
    }

    #exec { 'smw':
    #  command     => 'php composer.phar require mediawiki/semantic-media-wiki "~2.0"',
    #  cwd         => '/vagrant/mediawiki',
    #  user        => 'root',
    #  creates => '/vagrant/mediawiki/extensions/SemanticMediawiki',
    #  require => ''
    #}
mediawiki::extension{ 'SemanticMediaWiki':
   composer => true,
   needsupdate => true,
}


    mediawiki::extension{ 'Nuke': }

    mediawiki::extension{ 'BlockAndNuke':
      entrypoint => 'BlockandNuke.php',
      settings => {
        wgWhitelist => '/srv/vagrant/settings.d/DrmfUserWhitelist.txt'
      },
      require =>  File[ '/srv/vagrant/settings.d/DrmfUserWhitelist.txt' ],
    }
    #mediawiki::extension{ 'ParserFunctions': }
    #mediawiki::extension {'SemanticResultFormats': }
    #mediawiki::extension{ 'DynamicPageList': }
    #mediawiki::extension{ 'NukeDPL':
    #  require      => Mediawiki::Extension['DynamicPageList'],
   #}
}
