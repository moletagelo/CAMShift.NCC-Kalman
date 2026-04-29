function comparison = run_comparison_experiment(config)
%RUN_COMPARISON_EXPERIMENT 杩愯 KCF 涓庢敼杩?CAMshift 骞舵眹鎬诲姣旂粨鏋溿€?
    classicResult = run_classic_camshift_experiment(config);
    kcfResult = run_kcf_tracking_experiment(config);
    improvedResult = run_improved_camshift_experiment(config);

    comparison = struct();
    comparison.sequenceName = char(string(config.dataset.sequenceName));
    comparison.classicCamshift = classicResult;
    comparison.kcf = kcfResult;
    comparison.improvedCamshift = improvedResult;
    comparison.summary = struct();
    comparison.summary.classicCamshift = classicResult.metrics;
    comparison.summary.kcf = kcfResult.metrics;
    comparison.summary.improvedCamshift = improvedResult.metrics;
end
