function comparison = run_comparison_experiment(config)
%RUN_COMPARISON_EXPERIMENT 杩愯 KCF 涓庢敼杩?CAMshift 骞舵眹鎬诲姣旂粨鏋溿€?
    kcfResult = run_kcf_tracking_experiment(config);
    camshiftResult = run_improved_camshift_experiment(config);

    comparison = struct();
    comparison.sequenceName = char(string(config.dataset.sequenceName));
    comparison.kcf = kcfResult;
    comparison.camshift = camshiftResult;
    comparison.summary = struct();
    comparison.summary.kcf = kcfResult.metrics;
    comparison.summary.camshift = camshiftResult.metrics;
end
