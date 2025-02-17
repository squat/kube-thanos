{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'thanos-compact.rules',
        rules: [
          {
            alert: 'ThanosCompactMultipleCompactsAreRunning',
            annotations: {
              message: 'You should never run more than one Thanos Compact at once. You have {{ $value }}',
            },
            expr: 'sum(up{%(thanosCompactSelector)s}) > 1' % $._config,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ThanosCompactIsNotRunning',
            annotations: {
              message: 'Thanos Compaction is not running or just not scraped yet.',
            },
            expr: 'up{%(thanosCompactSelector)s} == 0 or absent({%(thanosCompactSelector)s})' % $._config,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ThanosCompactHalted',
            annotations: {
              message: 'Thanos Compact {{$labels.job}} has failed to run and now is halted.',
            },
            expr: 'thanos_compactor_halted{%(thanosCompactSelector)s} == 1' % $._config,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ThanosCompactHighCompactionFailures',
            annotations: {
              message: 'Thanos Compact {{$labels.job}} is failing to execute {{ $value | humanize }}% of compactions.',
            },
            expr: |||
              sum(
                rate(prometheus_tsdb_compactions_failed_total{%(thanosCompactSelector)s}[5m])
              /
                rate(prometheus_tsdb_compactions_total{%(thanosCompactSelector)s}[5m])
              ) by (job) * 100 > 5
            ||| % $._config,
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ThanosCompactBucketHighOperationFailures',
            annotations: {
              message: 'Thanos Compact {{$labels.job}} Bucket is failing to execute {{ $value | humanize }}% of operations.',
            },
            expr: |||
              sum(
                rate(thanos_objstore_bucket_operation_failures_total{%(thanosCompactSelector)s}[5m])
              /
                rate(thanos_objstore_bucket_operations_total{%(thanosCompactSelector)s}[5m])
              ) by (job) * 100 > 5
            ||| % $._config,
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'ThanosCompactHasNotRun',
            annotations: {
              message: 'Thanos Compact {{$labels.job}} has not uploaded anything for 24 hours.',
            },
            expr: '(time() - max(thanos_objstore_bucket_last_successful_upload_time{%(thanosCompactSelector)s})) / 60 / 60 > 24' % $._config,
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
